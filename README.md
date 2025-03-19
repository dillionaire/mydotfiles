# My Dotfiles

Personal configuration files for development environment setup.

## What's Included

### Shell Configuration
- `.zshrc` - Oh My Zsh configuration with custom plugins and settings
- `.zprofile` - Login shell configuration
- `.bash_profile` - Bash configuration (for compatibility)

### Development Tools
- VS Code settings
- Python environment setup (UV, IPython, Jupyter)
- Node.js setup (NVM)
- Go environment
- Docker configuration

### Additional Tools
- Cloudflared configuration
- n8n setup
- Jupyter and IPython configuration

## Installation

1. Clone this repository:
```bash
git clone https://github.com/dillionaire/mydotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Run the installer:
```bash
chmod +x install.sh
./install.sh
```

3. Reload your shell:
```bash
source ~/.zshrc
```

## Features

### Shell Configuration
- Oh My Zsh with af-magic theme
- Custom plugins including:
  - git: Git integration
  - vscode: VS Code integration
  - z: Directory jumping
  - zsh-autosuggestions
  - zsh-syntax-highlighting

### Development Environment
- UV for Python package management
- Go development setup
- Node.js with NVM
- Docker configuration
- VS Code settings and extensions

### Additional Features
- Cloudflared for secure tunneling
- n8n workflow automation
- Jupyter notebook configuration
- IPython setup
- Local bin directory in PATH

## Directory Structure
```
.
├── config/
│   ├── .zshrc
│   ├── .zprofile
│   ├── .bash_profile
│   └── vscode/
│       └── settings.json
├── install.sh
└── README.md
```

## Customization

To modify configurations:
1. Edit files in the `config/` directory
2. Run `source ~/.zshrc` to apply changes

Or use the alias:
```bash
zshconfig  # Opens .zshrc in VS Code
```

## Troubleshooting

### Common Issues

1. Oh My Zsh plugins not working:
```bash
ls ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/
```

2. UV not found:
```bash
brew install uv  # on macOS
```

3. VS Code settings not applied:
```bash
mkdir -p ~/.config/vscode
ln -sf ~/.dotfiles/config/vscode/settings.json ~/.config/vscode/settings.json
```
