# Dotfiles

Personal dotfiles configuration for quick setup on new macOS machines.

## System Requirements

- macOS (optimized for Apple Silicon)
- Git (for cloning the repository)
- Terminal access

## Prerequisites

The installation script will automatically install:
- Xcode Command Line Tools
- Homebrew
- Oh My Zsh with custom plugins
  - zsh-autosuggestions
  - zsh-syntax-highlighting

## Quick Start

```bash
# Clone the repository
mkdir -p ~/Code
git clone https://github.com/dillionaire/mydotfiles.git ~/Code/dotfiles
cd ~/Code/dotfiles

# Run the installation script
chmod +x install.sh
./install.sh

# Or skip already installed components
./install.sh --skip-existing

# After installation, restart your terminal
source ~/.zshrc
```

## What's Included

- `.zshrc` with Oh My Zsh configuration
- Custom Oh My Zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting)
- Git aliases and helpful shell functions
- Performance optimizations (lazy NVM loading)
- Automatic backup of existing configurations
- Backup/restore functionality
- Uninstall script

## Features

- **Organized Structure**: All development files in `~/Code`
- **Automated Setup**: One-command installation
- **Flexible Configuration**: Easy to customize
- **Backup System**: Automatic backup of existing files
- **Apple Silicon Optimized**: Specifically configured for M-series Macs

## Installation Details

The installation script:
1. Checks for and installs Xcode Command Line Tools
2. Installs Homebrew (with proper PATH configuration for Apple Silicon)
3. Installs Oh My Zsh with custom plugins
4. Creates necessary directory structure
5. Backs up existing configurations
6. Sets up symlinks for dotfiles

If any step fails, the script will provide clear error messages and instructions for manual intervention.

## Manual Steps After Installation

1. **Fabric**:
   - Install Fabric
   - Configure patterns in `~/.config/fabric/patterns`

2. **Obsidian**:
   - Set up vaults
   - Configure plugins

## Troubleshooting

If the installation stalls:
1. Run the script in debug mode: `bash -x install.sh`
2. Check Homebrew installation: `which brew`
3. Verify PATH setup: `echo $PATH`
4. Check Oh My Zsh installation: `echo $ZSH`

## Backup and Restore

### Creating a Backup

Before making changes or installing, create a backup:

```bash
./backup.sh
```

Backups are stored in `~/.dotfiles_backup/` with timestamps. Only the last 5 backups are kept.

### Restoring from Backup

To restore a previous configuration:

```bash
~/.dotfiles_backup/[timestamp]/restore.sh
```

## Updating

To update your dotfiles:

```bash
cd ~/Code/dotfiles
git pull
./install.sh --skip-existing  # Skip reinstalling existing tools
```

## Uninstalling

To remove the dotfiles configuration:

```bash
# Remove only dotfile symlinks
./uninstall.sh

# Remove dotfiles and all installed tools
./uninstall.sh --remove-tools
```

## Directory Structure

```
~/Code/
├── dotfiles/        # This repository
└── obsidian/        # Obsidian vaults

~/.dotfiles_backup/  # Automatic backups
└── [timestamp]/     # Backup with restore script
```