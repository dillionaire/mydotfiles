# codex-review.py — Claude ↔ Codex collaboration via shared markdown

A Stop hook that turns any markdown file into a turn-based review channel
between Claude Code and Codex. The shared file lives in your Obsidian vault
so you can watch the conversation both in Obsidian (on your MacBook, via git
sync) and in a terminal pane (on Chonk, via `chonk-collab watch`).

## Quick start (SSH workflow)

From your MacBook, SSH into Chonk and run:

```sh
cd ~/code/my-project
chonk-collab new auth-refactor --goal "Migrate session tokens to httpOnly cookies."
# (prints next steps)

# In pane 1:
claude
# Tell Claude: "Read agent-collab.md and follow the protocol. Plan in ## Plan,
#              then set frontmatter status: READY_FOR_REVIEW and stop."

# In pane 2:
chonk-collab watch auth-refactor
```

Each time Claude completes a stop handoff, the Stop hook invokes Codex
(`codex exec -s read-only`), appends the verdict to `## Review`, git-adds the
file, commits, and pushes to the vault remote — so within ~5 seconds your
MacBook sees the update in Obsidian too.

## `chonk-collab` CLI

Installed at `~/.local/bin/chonk-collab` (Python stdlib only).

| Command | What it does |
| --- | --- |
| `chonk-collab new <name> [--goal T] [--shared T] [--project-dir D] [--force]` | Creates `02-Projects/<name>/agent-collab.md` in the vault from the template. Merges env var + Stop hook into `<project-dir>/.claude/settings.json` (CWD by default). Preserves any existing settings. |
| `chonk-collab watch [name]` | Live-tail the file in the terminal. Re-renders with `bat` on every mtime change. Header shows status/turn/turns_left. Auto-selects if only one active collab exists. |
| `chonk-collab status [name]` / `list` | Table view of all collabs and their states. |
| `chonk-collab end [name]` | Manually sets `status: DONE`, logs it, git-syncs. Useful if a loop stalls and you want to close it out. |

Name-optional subcommands auto-pick the single active collab and error with a
disambiguation list if there are multiple.

## What the hook does

On every Claude `Stop` event:

1. Exit early unless `CLAUDE_CODEX_SHARED_FILE` is set and the file has
   frontmatter `status: READY_FOR_REVIEW` and `turn: claude`.
2. Decrement `turns_remaining`, mark `status: REVIEWING`, write to file.
3. Run `codex exec -s read-only` with a review prompt pointing at the file.
4. Append Codex's response to `## Review` and a handoff note to `## Log`.
5. Parse the `VERDICT:` line:
   - `APPROVED` → `status: APPROVED`, git-sync, allow Claude to stop.
   - `CHANGES_REQUESTED` → `status: DRAFTING`, git-sync, output
     `{"decision":"block",...}` to force Claude to revise with review as context.

## Git sync

The hook calls `git_sync(path, msg)` at every terminal state (APPROVED,
CHANGES_REQUESTED, ERROR, DONE/budget-exhausted). It:

- Walks up from the shared file to find `.git`
- `git add <just-this-file>` — won't touch your stack-sync's HEARTBEAT.md or
  anything else in the vault working tree
- Commits with a descriptive message
- Pushes with a 30 s timeout

All failures are non-fatal and logged to stderr. If the push loses a race to
your stack-sync's periodic job, the next stack-sync will rebase and push
both changes cleanly.

## Loop safety

- **Turn budget**: `turns_remaining` in frontmatter caps total review rounds
  (default 5). Reset manually in the file to run more.
- **`stop_hook_active`**: respected per Anthropic spec. After the hook blocks
  once and Claude resumes, the *next* stop in that cycle passes through —
  no unkillable loop. To run another review round, set
  `status: READY_FOR_REVIEW` again and prompt Claude.
- **Section ownership**: prevents write races without locks. Claude only
  touches `## Plan`, the hook only appends to `## Review` and `## Log`. You
  curate `## Goal` and `## Shared` between turns.
- **Atomic writes**: `tmp + rename`, so the file is never half-written.

## Failure-mode table

| Situation | Behavior |
| --- | --- |
| Env var not set | Exit 0 — hook is a no-op |
| File missing | Log to stderr, exit 0 |
| `codex` CLI not on PATH | `status: ERROR`, git-sync, exit 0 |
| Codex times out (>10 min) | `status: ERROR`, git-sync, exit 0 |
| Codex returns no `VERDICT:` line | Treat as `CHANGES_REQUESTED` (safe default) |
| `stop_hook_active: true` | Exit 0 — let Claude finish this cycle |
| Git push fails (auth / conflict) | Logged, non-fatal; next stack-sync rebases |

## Watching from Obsidian (MacBook)

The shared file syncs through your existing `dillionaire/vault` remote.
In Obsidian, `02-Projects/<name>/agent-collab.md` is a regular note — the
`## Log` section is a chronological feed, `## Review` accumulates Codex's
verdicts. For a dashboard across all active collabs, drop a Dataview query
somewhere like `00-Inbox/collabs.md`:

````md
```dataview
TABLE status, turn, turns_remaining, file.mtime AS "Last update"
FROM "02-Projects"
WHERE contains(file.name, "agent-collab") AND status
SORT file.mtime DESC
```
````

## Customizing

- **Sharper reviews**: edit the prompt inside `codex-review.py` (search for
  `"You are reviewing"`).
- **Different reviewer model**: pass `--model` to the `codex exec` invocation.
- **Skip the cap**: set `turns_remaining: 999` in frontmatter.
- **Disable git sync**: replace `git_sync` body with `return`. (Your
  stack-sync automation will still eventually catch the file.)
- **Codex with write access**: change `-s read-only` to `-s workspace-write`.
  Not recommended — breaks the safety property that only the hook touches
  `## Review`.
