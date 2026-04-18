#!/usr/bin/env python3
"""
Stop hook: hand off Claude's plan to Codex (read-only) for review via a shared markdown file.

Wiring (per-project .claude/settings.json):
    {
      "env": { "CLAUDE_CODEX_SHARED_FILE": "/abs/path/to/agent-collab.md" },
      "hooks": {
        "Stop": [{ "hooks": [{ "type": "command",
          "command": "/home/thomas/.claude/hooks/codex-review.py" }] }]
      }
    }

Behavior: no-op unless the shared file exists AND its frontmatter says
`status: READY_FOR_REVIEW` and `turn: claude`. Otherwise lets Claude stop normally.
On READY_FOR_REVIEW: invokes `codex exec -s read-only`, appends Codex's verdict
to the file, and either approves (clean stop) or blocks Claude with the review.

Loop safety: respects Stop-hook `stop_hook_active` (one review per stop cycle by
default) AND a `turns_remaining:` budget in frontmatter. Both must allow continuation.
"""

import json
import os
import re
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

CODEX_TIMEOUT_SEC = 600
DEFAULT_TURNS = 5
GIT_PUSH_TIMEOUT_SEC = 30


def log(msg: str) -> None:
    sys.stderr.write(f"[codex-review] {msg}\n")


def now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def git_sync(path: Path, message: str) -> None:
    """Best-effort: stage + commit + push just this file to its vault remote.

    Silently swallows all failures — never breaks the review loop. Skipped
    entirely if the shared file is not inside a git repo.
    """
    try:
        root = next((p for p in [path, *path.parents] if (p / ".git").exists()), None)
        if not root:
            return
        rel = str(path.relative_to(root))
        subprocess.run(
            ["git", "-C", str(root), "add", rel],
            check=False,
            timeout=10,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        commit = subprocess.run(
            ["git", "-C", str(root), "commit", "-m", message, "--", rel],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if commit.returncode != 0 and "nothing to commit" not in (
            commit.stdout + commit.stderr
        ):
            log(f"git commit skipped: {commit.stderr.strip() or commit.stdout.strip()}")
            return
        subprocess.run(
            ["git", "-C", str(root), "push"],
            check=False,
            timeout=GIT_PUSH_TIMEOUT_SEC,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception as e:
        log(f"git sync failed (non-fatal): {e}")


def parse_file(path: Path) -> tuple[dict, str]:
    text = path.read_text()
    if not text.startswith("---\n"):
        return {}, text
    end = text.find("\n---\n", 4)
    if end == -1:
        return {}, text
    fm: dict[str, str] = {}
    for line in text[4:end].splitlines():
        if ":" in line and not line.lstrip().startswith("#"):
            k, _, v = line.partition(":")
            fm[k.strip()] = v.strip()
    return fm, text[end + 5 :]


def write_file(path: Path, fm: dict, body: str) -> None:
    fm_text = "\n".join(f"{k}: {v}" for k, v in fm.items())
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(f"---\n{fm_text}\n---\n{body}")
    tmp.replace(path)


def append_to_section(body: str, section: str, content: str) -> str:
    """Append content to the end of a `## section` block (before the next `## ` or EOF)."""
    header = re.compile(rf"^##\s+{re.escape(section)}\s*$", re.MULTILINE)
    m = header.search(body)
    if not m:
        return body.rstrip() + f"\n\n## {section}\n\n{content}\n"
    after = body[m.end() :]
    next_m = re.search(r"^##\s+", after, re.MULTILINE)
    if next_m:
        insert_at = m.end() + next_m.start()
        before = body[:insert_at].rstrip()
        tail = body[insert_at:]
        return before + "\n\n" + content + "\n\n" + tail
    return body.rstrip() + "\n\n" + content + "\n"


def main() -> None:
    try:
        hook_input = json.load(sys.stdin)
    except Exception:
        hook_input = {}

    # Don't loop: if our previous block caused this stop, let Claude finish.
    if hook_input.get("stop_hook_active"):
        sys.exit(0)

    shared = os.environ.get("CLAUDE_CODEX_SHARED_FILE")
    if not shared:
        sys.exit(0)
    path = Path(shared).expanduser()
    if not path.exists():
        log(f"shared file missing: {path}")
        sys.exit(0)

    fm, body = parse_file(path)
    status = fm.get("status", "").upper()
    turn = fm.get("turn", "").lower()
    try:
        turns_remaining = int(fm.get("turns_remaining", DEFAULT_TURNS))
    except ValueError:
        turns_remaining = DEFAULT_TURNS

    if status != "READY_FOR_REVIEW" or turn != "claude":
        sys.exit(0)

    if turns_remaining <= 0:
        fm["status"] = "DONE"
        fm["turn"] = "done"
        body = append_to_section(
            body, "Log", f"- {now_iso()} **system**: turn budget exhausted"
        )
        write_file(path, fm, body)
        git_sync(path, f"agent-collab: {path.parent.name} DONE (turn budget)")
        sys.exit(0)

    # Mark handoff in flight
    fm["turn"] = "codex"
    fm["status"] = "REVIEWING"
    fm["turns_remaining"] = str(turns_remaining - 1)
    body = append_to_section(
        body,
        "Log",
        f"- {now_iso()} **claude→codex**: handoff (turns left: {turns_remaining - 1})",
    )
    write_file(path, fm, body)

    prompt = (
        f"You are reviewing a plan written by another AI agent (Claude Code).\n\n"
        f"Read this file: {path}\n\n"
        "Focus on the `## Plan` section. Critique it briefly (under 200 words) for:\n"
        "  - Correctness — will it actually solve the stated `## Goal`?\n"
        "  - Missed edge cases, risks, or hidden assumptions\n"
        "  - Simpler alternatives you'd recommend\n\n"
        "Be direct. Praise is cheap; specific objections are valuable.\n\n"
        "End your response with EXACTLY one of these on its own line:\n"
        "  VERDICT: APPROVED\n"
        "  VERDICT: CHANGES_REQUESTED\n\n"
        "Do not modify any files. Read-only review only."
    )

    with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=False) as tmp:
        out_path = tmp.name

    try:
        result = subprocess.run(
            [
                "codex",
                "exec",
                "-s",
                "read-only",
                "--output-last-message",
                out_path,
                prompt,
            ],
            capture_output=True,
            text=True,
            timeout=CODEX_TIMEOUT_SEC,
        )
    except FileNotFoundError:
        log("codex CLI not found on PATH")
        fm, body = parse_file(path)
        fm["status"] = "ERROR"
        fm["turn"] = "claude"
        body = append_to_section(
            body, "Log", f"- {now_iso()} **system**: codex CLI not found"
        )
        write_file(path, fm, body)
        git_sync(path, f"agent-collab: {path.parent.name} ERROR (codex not found)")
        sys.exit(0)
    except subprocess.TimeoutExpired:
        log(f"codex timed out after {CODEX_TIMEOUT_SEC}s")
        fm, body = parse_file(path)
        fm["status"] = "ERROR"
        fm["turn"] = "claude"
        body = append_to_section(
            body, "Log", f"- {now_iso()} **system**: codex timed out"
        )
        write_file(path, fm, body)
        git_sync(path, f"agent-collab: {path.parent.name} ERROR (codex timeout)")
        sys.exit(0)

    review_text = ""
    try:
        review_text = Path(out_path).read_text().strip()
    except OSError:
        pass
    finally:
        try:
            os.unlink(out_path)
        except OSError:
            pass

    if not review_text:
        review_text = (
            result.stdout or result.stderr or "(codex returned no output)"
        ).strip()

    verdict_match = re.search(r"VERDICT:\s*(APPROVED|CHANGES_REQUESTED)", review_text)
    verdict = verdict_match.group(1) if verdict_match else "CHANGES_REQUESTED"

    fm, body = parse_file(path)
    ts = now_iso()
    body = append_to_section(body, "Review", f"### {ts} — codex\n\n{review_text}")
    body = append_to_section(body, "Log", f"- {ts} **codex→claude**: {verdict}")

    if verdict == "APPROVED":
        fm["status"] = "APPROVED"
        fm["turn"] = "done"
        write_file(path, fm, body)
        git_sync(path, f"agent-collab: {path.parent.name} APPROVED")
        sys.exit(0)

    # CHANGES_REQUESTED: hand back to Claude with the review as the next instruction.
    fm["status"] = "DRAFTING"
    fm["turn"] = "claude"
    write_file(path, fm, body)
    git_sync(
        path,
        f"agent-collab: {path.parent.name} codex review (turn {DEFAULT_TURNS - (turns_remaining - 1)})",
    )

    print(
        json.dumps(
            {
                "decision": "block",
                "reason": (
                    f"Codex reviewed your ## Plan and requested changes. "
                    f"Read the latest entry under ## Review in {path}, revise the ## Plan, "
                    f"then set frontmatter `status: READY_FOR_REVIEW` and stop again to re-trigger review."
                ),
            }
        )
    )
    sys.exit(0)


if __name__ == "__main__":
    main()
