#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINKS_ONLY=false

if [[ "${1:-}" == "--links-only" ]]; then
  LINKS_ONLY=true
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--links-only]" >&2
  exit 2
fi

info() { printf '\033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '\033[33m!\033[0m %s\n' "$1"; }

install_packages() {
  case "$(uname -s)" in
    Darwin)
      if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required. Install it from https://brew.sh, then rerun this script." >&2
        exit 1
      fi
      brew install git zsh starship fzf zoxide eza bat
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y git zsh curl fzf zoxide eza bat
      else
        warn "Unsupported Linux package manager; install git, zsh, curl, fzf, zoxide, eza, bat, and Starship manually."
      fi
      if ! command -v starship >/dev/null 2>&1; then
        mkdir -p "$HOME/.local/bin"
        curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
      fi
      ;;
    *)
      warn "Unsupported OS; skipping package installation."
      ;;
  esac
}

clone_if_missing() {
  local repository="$1"
  local destination="$2"
  if [[ ! -d "$destination/.git" ]]; then
    git clone --depth 1 "$repository" "$destination"
  fi
}

install_shell_extensions() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c       "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$custom/plugins"
  clone_if_missing https://github.com/zsh-users/zsh-autosuggestions     "$custom/plugins/zsh-autosuggestions"
  clone_if_missing https://github.com/zsh-users/zsh-completions     "$custom/plugins/zsh-completions"
  clone_if_missing https://github.com/zdharma-continuum/fast-syntax-highlighting     "$custom/plugins/fast-syntax-highlighting"
}

link_file() {
  local source="$1"
  local target="$2"
  mkdir -p "$(dirname "$target")"

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
      info "$target already linked"
      return
    fi
    local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$target" "$backup"
    warn "Backed up $target to $backup"
  fi

  ln -s "$source" "$target"
  info "Linked $target"
}

if [[ "$LINKS_ONLY" == false ]]; then
  install_packages
  install_shell_extensions
fi

link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
link_file "$DOTFILES_DIR/.zshenv" "$HOME/.zshenv"
link_file "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
link_file "$DOTFILES_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"

echo
echo "Dotfiles installed. Start a new Zsh session with: exec zsh"
