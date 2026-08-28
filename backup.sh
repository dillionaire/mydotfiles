#!/usr/bin/env bash

set -euo pipefail

BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup_file() {
  local source="$1"
  local relative="$2"
  if [[ -e "$source" || -L "$source" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
    cp -a "$source" "$BACKUP_DIR/$relative"
    echo "Backed up $source"
  fi
}

backup_file "$HOME/.zshrc" .zshrc
backup_file "$HOME/.zprofile" .zprofile
backup_file "$HOME/.zshenv" .zshenv
backup_file "$HOME/.config/starship.toml" config/starship.toml
backup_file "$HOME/.config/ghostty/config" config/ghostty/config

echo "Backup created at $BACKUP_DIR"
