# Dotfiles

Personal dotfiles configuration for quick setup on new macOS machines.

## Quick Start

```bash
# Clone the repository
mkdir -p ~/Code
git clone https://github.com/dillionaire/mydotfiles.git ~/Code/dotfiles
cd ~/Code/dotfiles

# Run the installation script
chmod +x install.sh
./install.sh
```

## What's Included

- `.zshrc` with Oh My Zsh configuration
- Custom Oh My Zsh plugins
- Development tools configuration
- Automatic backup of existing configurations

## Features

- **Organized Structure**: All development files in `~/Code`
- **Automated Setup**: One-command installation
- **Flexible Configuration**: Easy to customize
- **Backup System**: Automatic backup of existing files
- **Cross-Platform**: Works on both Intel and Apple Silicon Macs

## Manual Steps After Installation

1. **Fabric**:
   - Install Fabric
   - Configure patterns in `~/.config/fabric/patterns`

2. **Obsidian**:
   - Set up vaults
   - Configure plugins

## Updating

To update your dotfiles:

```bash
cd ~/Code/dotfiles
git pull
./install.sh
```