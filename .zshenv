# Make the user-local Ubuntu Zsh package self-contained.
zsh_local_root="$HOME/.local/opt/zsh-5.9-8ubuntu3/usr"
if [[ -d "$zsh_local_root" ]]; then
  module_path=(
    "$zsh_local_root/lib/x86_64-linux-gnu/zsh/$ZSH_VERSION"
    $module_path
  )
  # Point every compiled-in function directory at the extracted package.
  fpath=(
    ${fpath/#\/usr\/share\/zsh\/functions/$zsh_local_root\/share\/zsh\/functions}
  )
fi
unset zsh_local_root

typeset -U path
path=("$HOME/.local/bin" $path)
export PATH

# Optional environment settings that should stay on one machine.
[[ -r "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"
