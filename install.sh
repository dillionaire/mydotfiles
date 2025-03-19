#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

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

# System-specific installations
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS specific setup
    if ! command -v brew >/dev/null 2>&1; then
        echo "${RED}Homebrew not found. Installing...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    echo "Installing macOS tools..."
    brew install uv go docker cloudflared n8n
    
    if ! command -v code >/dev/null 2>&1; then
        echo "Installing Visual Studio Code..."
        brew install --cask visual-studio-code
    fi
elif [[ "$IS_RASPBERRY_PI" == true ]]; then
    # Raspberry Pi specific setup
    echo "Setting up Raspberry Pi environment..."
    
    # Install UV
    if ! command -v uv >/dev/null 2>&1; then
        echo "Installing UV..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    
    # Install Docker
    if ! command -v docker >/dev/null 2>&1; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
    fi
else
    # Generic Linux setup
    echo "Installing Linux tools..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y python3-pip
    fi
fi

# Install NVM if not present
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    # Source NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # Install LTS version
    nvm install --lts
    nvm use --lts
fi

# Setup Python environment
if command -v uv >/dev/null 2>&1; then
    echo "Setting up Python environment..."
    uv pip install jupyter ipython matplotlib
fi

echo "${GREEN}Installation complete!${NC}"
echo "Please run 'source ~/.zshrc' to apply the changes."

if [[ "$IS_RASPBERRY_PI" == true ]]; then
    echo "\nRaspberry Pi Setup Notes:"
    echo "1. Consider running 'chsh -s $(which zsh)' to make zsh your default shell"
    echo "2. Some features may run slower on Raspberry Pi - see docs/raspberry-pi-setup.md"
    echo "3. For better performance, some plugins are disabled by default"
fi
