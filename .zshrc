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
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{blue}%B%d%b%f'

# Visible in dark terminal themes and accepted with Right Arrow or End.
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

# Modern, icon-aware listings (Ghostty/kitty supply Nerd Font glyph support).
if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza --long --all --git --icons=auto --group-directories-first'
  alias la='eza --all --icons=auto --group-directories-first'
  alias l='eza --long --icons=auto --group-directories-first'
  alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
fi
if (( $+commands[batcat] )); then
  alias bat='batcat'
fi

# Keep standard Emacs-style editing and add intuitive history search.
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

export EDITOR="vim"

# Everyday aliases.
alias zshconfig="$EDITOR ~/.zshrc"
alias zshreload="source ~/.zshrc && echo 'Zsh config reloaded'"
alias grep='grep --color=auto'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias -- -="cd -"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias gpl="git pull"
alias gm="git merge"
alias gst="git stash"
alias gstp="git stash pop"
(( $+commands[cursor] )) && alias c="cursor ."

# Small helpers.
mkcd() { mkdir -p "$1" && cd "$1"; }

backup() {
  if [[ -z "$1" ]]; then
    echo "Usage: backup <file>"
    return 1
  fi
  cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)" && echo "Backed up $1"
}

findtext() {
  if [[ -z "$1" ]]; then
    echo "Usage: findtext <text> [path]"
    return 1
  fi
  rg "$1" "${2:-.}"
}

# Lazy-load NVM so shell startup stays fast.
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
}
for _cmd in nvm node npm npx; do
  eval "$_cmd() { _load_nvm; unset -f nvm node npm npx; command $_cmd \"\$@\"; }"
done
unset _cmd

# uv / uvx completions when installed.
if (( $+commands[uv] )); then
  eval "$(uv generate-shell-completion zsh)"
  eval "$(uvx --generate-shell-completion zsh)"
fi

# Fabric patterns as shell functions (writes to the Obsidian vault when given a title).
obsidian_base="${OBSIDIAN_BASE:-$HOME/Code/obsidian}"
if [[ -d ~/.config/fabric/patterns ]] && [[ -n "$(ls -A ~/.config/fabric/patterns)" ]]; then
  for pattern_file in ~/.config/fabric/patterns/*; do
    pattern_name=$(basename "$pattern_file")
    if [[ "$pattern_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
      unalias "$pattern_name" 2>/dev/null
      eval "
      $pattern_name() {
        local title=\$1
        local date_stamp=\$(date +'%Y-%m-%d')
        local output_path=\"\$obsidian_base/\${date_stamp}-\${title}.md\"
        if [ -n \"\$title\" ]; then
          fabric --pattern \"$pattern_name\" -o \"\$output_path\"
        else
          fabric --pattern \"$pattern_name\" --stream
        fi
      }
      "
    fi
  done
fi
yt() { fabric -y "$1" --transcript; }

export N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# kitty terminal: kittens are only useful inside kitty itself.
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ssh="kitten ssh"      # copies terminfo to the remote host automatically
  alias icat="kitten icat"    # inline images
  alias kdiff="kitten diff"   # side-by-side diff with images
fi

# macOS-only conveniences.
if [[ "$OSTYPE" == darwin* ]]; then
  alias update="brew update && brew upgrade"
  alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
  alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
  [[ -x "$HOME/.claude/local/claude" ]] && alias claude="_load_nvm && $HOME/.claude/local/claude"
  [[ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]] && alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
  # Chonk API key lives in the login Keychain, never in a file.
  if [[ -o interactive ]]; then
    chonk_key="$(security find-generic-password -a "$USER" -s CHONK_API_KEY -w 2>/dev/null)"
    [[ -n "$chonk_key" ]] && export CHONK_API_KEY="$chonk_key"
    unset chonk_key
  fi
else
  alias update="sudo apt update && sudo apt upgrade -y"
fi

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# Optional settings that should stay on one machine.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
