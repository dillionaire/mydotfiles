# My Dotfiles

Personal configuration files for development environment setup.

## Prerequisites

1. Install Oh My Zsh:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

2. Install required Oh My Zsh plugins:
```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

3. Install other dependencies:
```bash
# On macOS
brew install uv go

# Install Node Version Manager (nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/dillionaire/mydotfiles.git ~/.dotfiles
```

2. Create symbolic links:
```bash
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
```

3. Reload your shell:
```bash
source ~/.zshrc
```

## Features

### Oh My Zsh Configuration
- Theme: af-magic
- Plugins:
  - git: Git integration and aliases
  - vscode: VS Code integration
  - z: Quick directory jumping
  - zsh-autosuggestions: Fish-like autosuggestions
  - zsh-syntax-highlighting: Fish-like syntax highlighting

### Development Tools
- UV package manager for Python
- Golang environment setup
- NVM (Node Version Manager)
- Fabric integration for note-taking

### Quality of Life Features
- OS-specific aliases (different for macOS and Linux)
- Path deduplication
- Performance optimizations
- Homebrew integration
- VS Code integration

## Customization

To modify the configuration:
1. Edit `~/.dotfiles/.zshrc`
2. Run `source ~/.zshrc` to apply changes

Or use the alias:
```bash
zshconfig  # Opens .zshrc in VS Code
```

## Troubleshooting

### Plugin Issues
If plugins aren't working, ensure they're installed:
```bash
ls ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/
```

Should show:
- zsh-autosuggestions
- zsh-syntax-highlighting

### UV Integration
If UV commands aren't working, ensure it's installed:
```bash
brew install uv  # on macOS
```
