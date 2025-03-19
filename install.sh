#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Installing dotfiles..."

# Create necessary directories
mkdir -p "$HOME/.config/vscode"
mkdir -p "$HOME/bin"

# Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "${RED}Oh My Zsh not found. Installing...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install Oh My Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

# Install zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# Backup existing files
for file in .zshrc .bash_profile .zprofile; do
    if [ -f "$HOME/$file" ]; then
        echo "Backing up existing $file..."
        mv "$HOME/$file" "$HOME/$file.backup.$(date +%Y%m%d_%H%M%S)"
    fi
done

# Create symbolic links
echo "Creating symbolic links..."
ln -sf "$PWD/config/.zshrc" "$HOME/.zshrc"
ln -sf "$PWD/config/.bash_profile" "$HOME/.bash_profile"
ln -sf "$PWD/config/.zprofile" "$HOME/.zprofile"
ln -sf "$PWD/config/vscode/settings.json" "$HOME/.config/vscode/settings.json"

# Check if running on macOS
if [[ "$(uname)" == "Darwin" ]]; then
    # Check if Homebrew is installed
    if ! command -v brew >/dev/null 2>&1; then
        echo "${RED}Homebrew not found. Installing...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install essential tools
    echo "Installing essential tools..."
    brew install uv go docker cloudflared n8n

    # Install VS Code if not present
    if ! command -v code >/dev/null 2>&1; then
        echo "Installing Visual Studio Code..."
        brew install --cask visual-studio-code
    fi
fi

# Install NVM if not present
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Setup Python environment
if command -v uv >/dev/null 2>&1; then
    echo "Setting up Python environment..."
    uv pip install jupyter ipython matplotlib
fi

echo "${GREEN}Installation complete!${NC}"
echo "Please run 'source ~/.zshrc' to apply the changes."
