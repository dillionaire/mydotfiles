#!/bin/bash

# ------------------------------------------------------------
# Run the script with:
# chmod +x install.sh
# ./install.sh [--skip-existing]
# ------------------------------------------------------------

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Parse arguments
SKIP_EXISTING=false
for arg in "$@"; do
    case $arg in
        --skip-existing)
            SKIP_EXISTING=true
            ;;
    esac
done

# Validate macOS version
if [[ ! "$OSTYPE" == "darwin"* ]]; then
    echo -e "${RED}❌ This script is designed for macOS only${NC}"
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Progress indicator
progress() {
    echo -e "${GREEN}✓${NC} $1"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo "🚀 Starting dotfiles installation..."
echo "Options: skip-existing=$SKIP_EXISTING"

# Install Xcode Command Line Tools if needed
if ! xcode-select -p &> /dev/null; then
    echo "📦 Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "⏳ Please wait for Xcode Command Line Tools to install and press any key to continue..."
    read -n 1
    
    # Verify installation
    if ! xcode-select -p &> /dev/null; then
        error "Xcode Command Line Tools installation failed"
        exit 1
    fi
    progress "Xcode Command Line Tools installed"
else
    progress "Xcode Command Line Tools already installed"
fi

# Install Homebrew if needed
if ! command -v brew &> /dev/null; then
    if [ "$SKIP_EXISTING" = true ]; then
        warning "Homebrew not installed, skipping (--skip-existing flag)"
    else
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            error "Homebrew installation failed"
            exit 1
        }

        echo "🔄 Configuring Homebrew for Apple Silicon..."
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        # Verify Homebrew installation and PATH
        if ! command -v brew &> /dev/null; then
            error "Homebrew installation failed or PATH not set correctly"
            echo "Manual step needed: restart your terminal or run:"
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
            exit 1
        fi

        progress "Homebrew installed and configured"
    fi
else
    progress "Homebrew already installed"
fi

# Install Oh My Zsh if needed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "💻 Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
        error "Oh My Zsh installation failed"
        exit 1
    }
    progress "Oh My Zsh installed"
else
    progress "Oh My Zsh already installed"
fi

# Install Oh My Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "🔌 Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" || {
        error "zsh-autosuggestions installation failed"
        warning "You can install it manually later"
    }
    progress "zsh-autosuggestions installed"
else
    progress "zsh-autosuggestions already installed"
fi

# Install zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "🎨 Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" || {
        error "zsh-syntax-highlighting installation failed"
        warning "You can install it manually later"
    }
    progress "zsh-syntax-highlighting installed"
else
    progress "zsh-syntax-highlighting already installed"
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p "$HOME/Code/obsidian"

# Backup existing .zshrc if it exists and is not a symlink
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    echo "💾 Backing up existing .zshrc..."
    mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Symlink dotfiles
echo "🔗 Creating symlinks..."
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Create .config directory for app configs
echo "📁 Creating app config directories..."
mkdir -p "$HOME/.config/ghostty"

# Symlink app configs
echo "🔗 Symlinking app configs..."
ln -sf "$DOTFILES_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"
ln -sf "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"

# Claude Code hooks + chonk-collab CLI
echo "📁 Creating Claude hooks + bin directories..."
mkdir -p "$HOME/.claude/hooks" "$HOME/.local/bin"

echo "🔗 Symlinking Claude hooks..."
ln -sf "$DOTFILES_DIR/claude/hooks/codex-review.py" "$HOME/.claude/hooks/codex-review.py"
ln -sf "$DOTFILES_DIR/claude/hooks/codex-review.README.md" "$HOME/.claude/hooks/codex-review.README.md"

echo "🔗 Symlinking chonk-collab CLI..."
ln -sf "$DOTFILES_DIR/bin/chonk-collab" "$HOME/.local/bin/chonk-collab"

# Summary
echo ""
echo "======================================"
echo "✨ Installation complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Verify installation with: zshconfig"
echo ""
echo "Installed components:"
[ -x "$(command -v brew)" ] && progress "Homebrew"
[ -d "$HOME/.oh-my-zsh" ] && progress "Oh My Zsh"
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && progress "zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && progress "zsh-syntax-highlighting"
[ -L "$HOME/.zshrc" ] && progress "Dotfiles symlinked"
[ -L "$HOME/.config/ghostty/config" ] && progress "Ghostty config"
[ -L "$HOME/.config/starship.toml" ] && progress "Starship config"
[ -L "$HOME/.claude/hooks/codex-review.py" ] && progress "Claude codex-review hook"
[ -L "$HOME/.local/bin/chonk-collab" ] && progress "chonk-collab CLI"