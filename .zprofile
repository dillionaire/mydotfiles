# Login-shell paths.
typeset -U path
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.cargo/bin"
  $path
)
[[ -d "$HOME/.local/share/pi-node/current/bin" ]] &&
  path=("$HOME/.local/share/pi-node/current/bin" $path)

# macOS: Homebrew (Apple Silicon or Intel) and VS Code's `code` CLI.
if [[ "$OSTYPE" == darwin* ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  [[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]] &&
    path+=("/Applications/Visual Studio Code.app/Contents/Resources/app/bin")
fi
export PATH
