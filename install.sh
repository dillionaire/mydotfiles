#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Installing dotfiles..."

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

# Backup existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc..."
    mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Create symbolic link for .zshrc
echo "Creating symbolic link for .zshrc..."
ln -sf "$PWD/.zshrc" "$HOME/.zshrc"

# Check if running on macOS
if [[ "$(uname)" == "Darwin" ]]; then
    # Check if Homebrew is installed
    if ! command -v brew >/dev/null 2>&1; then
        echo "${RED}Homebrew not found. Installing...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install UV if not present
    if ! command -v uv >/dev/null 2>&1; then
        echo "Installing UV..."
        brew install uv
    fi

    # Install Go if not present
    if ! command -v go >/dev/null 2>&1; then
        echo "Installing Go..."
        brew install go
    fi
fi

# Install NVM if not present
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

echo "${GREEN}Installation complete!${NC}"
echo "Please run 'source ~/.zshrc' to apply the changes."
