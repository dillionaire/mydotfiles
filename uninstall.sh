#!/bin/bash

# ------------------------------------------------------------
# Uninstall dotfiles and optionally remove installed tools
# Usage: ./uninstall.sh [--remove-tools]
# ------------------------------------------------------------

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Parse arguments
REMOVE_TOOLS=false
for arg in "$@"; do
    case $arg in
        --remove-tools)
            REMOVE_TOOLS=true
            shift
            ;;
    esac
done

echo "🗑️  Starting dotfiles uninstallation..."
echo "Options: remove-tools=$REMOVE_TOOLS"
echo ""

# Confirmation
echo -e "${YELLOW}⚠️  This will remove the dotfiles configuration.${NC}"
if [ "$REMOVE_TOOLS" = true ]; then
    echo -e "${YELLOW}⚠️  This will also remove Oh My Zsh and optionally Homebrew.${NC}"
fi
echo ""
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Create backup before uninstalling
echo ""
echo "Creating backup before uninstall..."
if [ -f "./backup.sh" ]; then
    ./backup.sh
else
    echo -e "${YELLOW}⚠️  backup.sh not found, skipping backup${NC}"
fi

# Remove symlinks
echo ""
echo "Removing dotfile symlinks..."
[ -L "$HOME/.zshrc" ] && rm "$HOME/.zshrc" && echo -e "${GREEN}✓${NC} Removed .zshrc symlink"

# Remove dotfiles directory from PATH in .zprofile
if [ -f "$HOME/.zprofile" ]; then
    echo "Cleaning .zprofile..."
    # Remove Homebrew PATH entries without creating backup file
    sed -i '' '/eval.*homebrew.*shellenv/d' "$HOME/.zprofile"
    echo -e "${GREEN}✓${NC} Cleaned .zprofile"
fi

# Optionally remove tools
if [ "$REMOVE_TOOLS" = true ]; then
    echo ""
    echo "Removing installed tools..."
    
    # Remove Oh My Zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Removing Oh My Zsh..."
        rm -rf "$HOME/.oh-my-zsh"
        echo -e "${GREEN}✓${NC} Removed Oh My Zsh"
    fi
    
    # Ask about Homebrew
    if command -v brew &> /dev/null; then
        echo ""
        echo -e "${YELLOW}Homebrew is installed. Remove it?${NC}"
        echo "Warning: This will remove ALL Homebrew packages!"
        read -p "Remove Homebrew? (y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Uninstalling Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
            echo -e "${GREEN}✓${NC} Removed Homebrew"
        else
            echo "Keeping Homebrew installed"
        fi
    fi
fi

# Final cleanup
echo ""
echo "========================================"
echo "✅ Uninstall complete!"
echo "========================================"
echo ""
echo "The following items were removed:"
echo "- Dotfile symlinks"
[ "$REMOVE_TOOLS" = true ] && [ ! -d "$HOME/.oh-my-zsh" ] && echo "- Oh My Zsh"
[ "$REMOVE_TOOLS" = true ] && ! command -v brew &> /dev/null && echo "- Homebrew"
echo ""
echo "The following items were kept:"
echo "- Dotfiles repository at ~/Code/dotfiles"
echo "- Backups in ~/.dotfiles_backup"
[ -d "$HOME/Code/obsidian" ] && echo "- Obsidian directory"
echo ""
echo "To completely remove all traces:"
echo "  rm -rf ~/Code/dotfiles"
echo "  rm -rf ~/.dotfiles_backup"
echo ""
echo "Please restart your terminal or start a new shell session."