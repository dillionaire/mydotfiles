#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running in zsh
if [ -z "$ZSH_VERSION" ]; then
    echo "${RED}Error: This script should be run in zsh.${NC}"
    echo "${YELLOW}Please switch to zsh first:${NC}"
    echo "1. Run: chsh -s \$(which zsh)"
    echo "2. Log out and log back in"
    echo "3. Verify with: echo \$SHELL"
    echo "4. Then run this script again"
    exit 1
fi

echo "Installing dotfiles..."

# Detect system architecture
ARCH=$(uname -m)
IS_RASPBERRY_PI=false
if [[ "$ARCH" == "armv7l" ]] || [[ "$ARCH" == "aarch64" ]]; then
    IS_RASPBERRY_PI=true
    echo "Detected Raspberry Pi architecture: $ARCH"
    
    # Raspberry Pi specific optimizations
    echo "Adding Raspberry Pi optimizations..."
    echo "\n# Raspberry Pi Performance Optimizations\nDISABLE_AUTO_UPDATE=true\nZSH_DISABLE_COMPFIX=true" >> config/.zshrc
fi

# Create necessary directories
mkdir -p "$HOME/.config/vscode"
mkdir -p "$HOME/bin"

# Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "${RED}Oh My Zsh not found. Installing...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Restore our .zshrc if Oh My Zsh installation overwrote it
    if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
        mv "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc"
    fi
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

[Rest of the install script remains the same...]

echo "${GREEN}Installation complete!${NC}"
echo "Please run 'source ~/.zshrc' to apply the changes."

if [[ "$IS_RASPBERRY_PI" == true ]]; then
    echo "\nRaspberry Pi Setup Notes:"
    echo "1. Your shell is already zsh (verified at start)"
    echo "2. Some features may run slower on Raspberry Pi - see docs/raspberry-pi-setup.md"
    echo "3. For better performance, some plugins are disabled by default"
    echo "\nTest your setup with:"
    echo "1. echo \$ZSH_VERSION  # Should show zsh version"
    echo "2. echo \$ZSH_THEME   # Should show 'af-magic'"
    echo "3. Try using git commands - should show completions"
fi
