#!/bin/bash

# ------------------------------------------------------------
# Backup existing dotfiles before installation
# Usage: ./backup.sh
# ------------------------------------------------------------

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Create backup directory with timestamp
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

echo "🔒 Creating backup of existing dotfiles..."
echo "Backup location: $BACKUP_DIR"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to backup a file/directory
backup_item() {
    local item="$1"
    local name=$(basename "$item")
    
    if [ -e "$item" ]; then
        echo -e "${GREEN}✓${NC} Backing up $item"
        cp -r "$item" "$BACKUP_DIR/$name"
    else
        echo -e "${YELLOW}⚠️${NC} $item not found, skipping"
    fi
}

# Backup important files and directories
backup_item "$HOME/.zshrc"
backup_item "$HOME/.zprofile"
backup_item "$HOME/.oh-my-zsh"
backup_item "$HOME/.config"

# Create restore script
cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash

# Restore script for this backup
set -e

BACKUP_DIR="$(dirname "$0")"

echo "🔄 Restoring dotfiles from backup..."

# Function to restore a file/directory
restore_item() {
    local name="$1"
    local target="$HOME/$name"
    
    if [ -e "$BACKUP_DIR/$name" ]; then
        echo "Restoring $name"
        # Remove existing file/directory
        [ -e "$target" ] && rm -rf "$target"
        # Copy from backup
        cp -r "$BACKUP_DIR/$name" "$target"
    fi
}

# Restore files
restore_item ".zshrc"
restore_item ".zprofile"
restore_item ".oh-my-zsh"
restore_item ".config"

echo "✅ Restore complete! Please restart your terminal."
EOF

chmod +x "$BACKUP_DIR/restore.sh"

# Save backup info
cat > "$BACKUP_DIR/backup_info.txt" << EOF
Dotfiles Backup
===============
Date: $(date)
User: $USER
Host: $(hostname)

Files backed up:
$(ls -la "$BACKUP_DIR" | grep -v "backup_info.txt" | grep -v "restore.sh")

To restore this backup, run:
$BACKUP_DIR/restore.sh
EOF

echo ""
echo "========================================"
echo "✅ Backup complete!"
echo "========================================"
echo ""
echo "Backup location: $BACKUP_DIR"
echo "To restore, run: $BACKUP_DIR/restore.sh"
echo ""

# Keep only the last 5 backups
if [ -d "$HOME/.dotfiles_backup" ]; then
    echo "Cleaning old backups (keeping last 5)..."
    # Use nullglob and array to safely handle filenames
    shopt -s nullglob
    backups=("$HOME/.dotfiles_backup"/*/)
    if [ "${#backups[@]}" -gt 5 ]; then
        sorted=($(printf '%s\n' "${backups[@]}" | sort))
        for backup in "${sorted[@]:0:$(( ${#sorted[@]} - 5 ))}"; do
            rm -rf "$backup"
        done
    fi
    shopt -u nullglob
fi