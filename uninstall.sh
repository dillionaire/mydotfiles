#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

remove_managed_link() {
  local source="$1"
  local target="$2"
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    rm "$target"
    echo "Removed $target"
  fi
}

remove_managed_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
remove_managed_link "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
remove_managed_link "$DOTFILES_DIR/.zshenv" "$HOME/.zshenv"
remove_managed_link "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
remove_managed_link "$DOTFILES_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"

echo "Managed symlinks removed. Installed tools and backups were left untouched."
