# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

Personal dotfiles for macOS (Apple Silicon) and Ubuntu. Files are symlinked from
this repo into `$HOME` by `install.sh`; edit them in place and commit. The
user-facing overview lives in `README.md`.

## Layout

- `.zshrc`, `.zprofile`, `.zshenv` — Zsh. Oh My Zsh plugins, Starship prompt,
  zoxide/fzf/eza, lazy-loaded NVM, git aliases. macOS-only bits are guarded by
  `$OSTYPE == darwin*`. Machine-local overrides go in untracked `~/.zshrc.local`
  and `~/.zshenv.local`.
- `config/starship.toml` — prompt (Catppuccin Mocha palette).
- `config/ghostty/config` — Ghostty terminal.
- `config/kitty/kitty.conf`, `config/kitty/current-theme.conf` — kitty terminal,
  tuned for the M4 Pro MacBook (JetBrainsMono Nerd Font Mono, 120 Hz repaint,
  splits layout, cmd-key bindings). Swap themes with `kitten themes`.
- `claude/hooks/codex-review.py` — Claude Code Stop hook that hands plans to
  Codex (read-only) for review via a shared markdown file in the Obsidian vault.
  Details in `claude/hooks/codex-review.README.md`.
- `bin/chonk-collab` — CLI to bootstrap/watch/end Claude ↔ Codex review sessions.
  `chonk-collab new <name> --goal "..."` creates the vault file and wires the Stop
  hook into the project's `.claude/settings.json`.
- `install.sh` (`--links-only` skips package installs), `backup.sh`, `uninstall.sh`.

## Working here

- Add a new config under `config/`, then add a `link_file` line to `install.sh`
  and matching lines to `backup.sh` and `uninstall.sh`.
- Keep `.zshrc` portable: guard OS-specific code and check `$+commands[...]`
  before using optional tools.
- Validate with `bash -n install.sh backup.sh uninstall.sh` and `zsh -n .zshrc`.
- Claude Code sessions on the Mac usually run inside kitty; never kill kitty
  from a script. kitty reloads `kitty.conf` automatically on save.
