# A small Oh My Zsh setup; Starship owns the prompt.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
DISABLE_AUTO_TITLE="true"
HYPHEN_INSENSITIVE="true"

# History shared across sessions.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# Load additional completion definitions before Oh My Zsh initializes compinit.
fpath=("$ZSH/custom/plugins/zsh-completions/src" $fpath)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Visible in Ghostty's dark themes and accepted with Right Arrow or End.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80

plugins=(
  git
  fzf
  colored-man-pages
  extract
  command-not-found
  sudo
  zsh-autosuggestions
  history-substring-search
  fast-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# Fast navigation: `z fragment` jumps to a frequently used directory.
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# Modern, icon-aware listings (Ghostty supplies Nerd Font glyph support).
if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza --long --all --git --icons=auto --group-directories-first'
  alias la='eza --all --icons=auto --group-directories-first'
  alias l='eza --long --icons=auto --group-directories-first'
fi
if (( $+commands[batcat] )); then
  alias bat='batcat'
fi

# Keep standard Emacs-style editing and add intuitive history search.
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

eval "$(starship init zsh)"

# Optional settings that should stay on one machine.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
