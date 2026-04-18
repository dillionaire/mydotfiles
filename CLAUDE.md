# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository designed for quick setup on new macOS machines, specifically optimized for Apple Silicon (M-series) Macs. The repository provides a streamlined installation process that sets up a complete development environment with Zsh, Oh My Zsh, and various development tools.

## Architecture & Key Components

### Core Files

- **install.sh** - Main installation script with validation, error handling, and --skip-existing option
- **.zshrc** - Zsh configuration with Oh My Zsh, performance optimizations, git aliases, and utility functions
- **backup.sh** - Creates timestamped backups of dotfiles with restore capability
- **uninstall.sh** - Removes dotfiles configuration with optional tool removal
- **README.md** - User-facing documentation with installation instructions
- **claude/hooks/** - Claude Code Stop hook scripts (symlinked into ~/.claude/hooks/)
  - `codex-review.py` - Stop hook that hands off plans to Codex (read-only) for
    review via a shared markdown file in the Obsidian vault. Git-syncs the file
    on each verdict so both machines stay in sync. See `codex-review.README.md`.
- **bin/** - Executables symlinked into ~/.local/bin
  - `chonk-collab` - CLI to bootstrap/watch/end Claude ↔ Codex review sessions.
    `chonk-collab new <name> --goal "..."` creates a vault file, wires the Stop
    hook into the project's `.claude/settings.json`, and prints next steps.

### Directory Structure Created

```
~/Code/
├── dotfiles/        # This repository
└── obsidian/       # Obsidian vaults directory
```

## Common Development Tasks

### Running the Installation

```bash
# Initial installation
chmod +x install.sh
./install.sh

# Skip existing components
./install.sh --skip-existing

# Create backup
./backup.sh

# Uninstall
./uninstall.sh              # Remove symlinks only
./uninstall.sh --remove-tools  # Remove everything

# Update existing installation
cd ~/Code/dotfiles
git pull
./install.sh --skip-existing
```

### Testing Changes

After modifying dotfiles:

```bash
# Reload shell configuration
source ~/.zshrc

# Verify PATH and environment variables
echo $PATH
echo $GOPATH
which brew
```

## Installation Process Details

The install.sh script performs these steps in order:

1. **macOS Validation** - Ensures script runs only on macOS
2. **Xcode Command Line Tools** - Checks and installs if missing with verification
3. **Homebrew** - Installs and configures for Apple Silicon (/opt/homebrew) or Intel (/usr/local)
4. **Oh My Zsh** - Installs with RUNZSH=no and CHSH=no flags
5. **Zsh Plugins** - Installs zsh-autosuggestions and zsh-syntax-highlighting
6. **Directory Structure** - Creates ~/Code/obsidian
7. **Dotfile Symlinks** - Creates symlink from repo .zshrc to ~/.zshrc with backup

### Script Features

- Color-coded output with progress indicators
- `--skip-existing` flag to skip already installed components
- Error handling with helpful messages
- Installation summary at completion

## Zsh Configuration Details

### Oh My Zsh Configuration

- **Theme**: af-magic
- **Plugins**: git, vscode, z, zsh-autosuggestions, zsh-syntax-highlighting

### Environment Variables

- **PATH**: Includes /opt/homebrew/bin, ~/.local/bin, LM Studio CLI
- **NVM_DIR**: $HOME/.nvm (for Node.js version management)
- **OBSIDIAN_BASE**: Defaults to $HOME/Code/obsidian

### Key Aliases

#### Basic Commands

- `zshconfig` - Opens .zshrc in VS Code
- `zshreload` - Reloads shell configuration
- `ll`, `la`, `l` - Various ls shortcuts
- `c` - Opens current directory in VS Code

#### Directory Navigation

- `..`, `...`, `....` - Navigate up directories
- `~` - Go to home directory
- `-` - Go to previous directory

#### Git Aliases

- `gs` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `gl` - git log (formatted)
- `gd` - git diff
- `gco` - git checkout
- `gb` - git branch
- `gpl` - git pull
- `gm` - git merge
- `gst` - git stash
- `gstp` - git stash pop

#### macOS Specific

- `update` - brew update && brew upgrade
- `showfiles` - Show hidden files in Finder
- `hidefiles` - Hide hidden files in Finder

### Utility Functions

- **mkcd** - Create directory and cd into it
- **backup** - Quick backup with timestamp
- **extract** - Extract various archive formats
- **findtext** - Search for text in files

## Dependencies and External Tools

### Required Dependencies

- macOS (optimized for Apple Silicon)
- Git
- Internet connection for downloading tools

### Tools Installed by Script

- Xcode Command Line Tools
- Homebrew
- Oh My Zsh
- zsh-autosuggestions plugin
- zsh-syntax-highlighting plugin

### Tools Referenced but Not Installed

- Node.js (via NVM)
- VS Code
- UV (Python package manager)
- LM Studio CLI
- Obsidian (note-taking app)

## Adding New Configurations

When adding new dotfiles:

1. Place the file in the repository root
2. Update install.sh to create a symlink in the appropriate location
3. Add backup logic similar to the .zshrc handling
4. Document any new dependencies or manual steps in README.md

## Troubleshooting

### Common Issues

1. **Homebrew PATH not set**: The script adds Homebrew to .zprofile, but you may need to restart terminal
2. **Oh My Zsh plugins not loading**: Ensure the custom plugins are properly cloned to $ZSH_CUSTOM/plugins/
3. **Obsidian directory warning**: Normal if Obsidian isn't set up yet; the directory is created for future use

### Debug Mode

Run installation in debug mode:

```bash
bash -x install.sh
```

## Important Notes

- The installation script uses `set -e` to exit on any error
- Existing .zshrc files are backed up with timestamp before symlinking
- The script is idempotent - safe to run multiple times
- All installations check for existing installations to avoid duplicates
- Apple Silicon Macs use /opt/homebrew instead of /usr/local for Homebrew
- NVM is lazy-loaded for faster shell startup
- Oh My Zsh plugins are already loaded by the framework (no duplicate sourcing)
- Backup script keeps only the last 5 backups to save space
- Uninstall script creates a backup before removing configuration
