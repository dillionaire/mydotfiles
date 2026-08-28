# Login-shell paths.
typeset -U path
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  $path
)
[[ -d "$HOME/.local/share/pi-node/current/bin" ]] &&
  path=("$HOME/.local/share/pi-node/current/bin" $path)
export PATH
