# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Command paths must be available before plugin selection.
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '!a[$1]++' | sed 's/:$//')

# Theme for Oh My Zsh
# Theme disabled - using Starship prompt instead
ZSH_THEME=""

# History shared by zsh, autosuggestions, and fzf.
export HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# Keep the Oh My Zsh z plugin as a fallback until zoxide is available.
plugins=(git vscode zsh-autosuggestions fast-syntax-highlighting)
(( $+commands[zoxide] )) || plugins+=(z)

# Load Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# Expanded, forgiving Tab completion.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=** r:|=**' \
    'l:|=* r:|=*'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{blue}%B%d%b%f'

# Default editor
export EDITOR="vim"

# Lazy load NVM for faster shell startup
export NVM_DIR="$HOME/.nvm"

_load_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

nvm() {
    _load_nvm
    unset -f nvm
    command nvm "$@"
}

node() {
    _load_nvm
    unset -f node
    command node "$@"
}

npm() {
    _load_nvm
    unset -f npm
    command npm "$@"
}

npx() {
    _load_nvm
    unset -f npx
    command npx "$@"
}

# Base directory for Obsidian notes
obsidian_base="${OBSIDIAN_BASE:-$HOME/Code/obsidian}"

# Dynamically define functions based on pattern files in a specific directory
if [ -d ~/.config/fabric/patterns ] && [ "$(ls -A ~/.config/fabric/patterns)" ]; then
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

# Define a shortcut for fabric commands with YouTube links
yt() {
    local video_link="$1"
    fabric -y "$video_link" --transcript
}

# ==================== ALIASES ====================

# Basic aliases
alias zshconfig="$EDITOR ~/.zshrc"
alias zshreload="source ~/.zshrc && echo 'Zsh config reloaded'"

# Prefer eza for listings, with portable fallbacks on machines without it.
if (( $+commands[eza] )); then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza -lh --icons=auto --group-directories-first --git'
    alias la='eza -lah --icons=auto --group-directories-first --git'
    alias l='eza -1 --icons=auto --group-directories-first'
    alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
else
    alias ll='ls -la'
    alias la='ls -A'
    alias l='ls -CF'
fi

# Colored grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Enable aliases to be sudo'ed
alias sudo='sudo '

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias -- -="cd -"

# Git aliases
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

# Cursor AI
alias c="cursor ."

# OS-specific aliases
case "$(uname)" in
    Linux)
        alias update="sudo apt update && sudo apt upgrade -y"
        ;;
    Darwin)
        alias update="brew update && brew upgrade"
        alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
        alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
        ;;
esac

# ==================== FUNCTIONS ====================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick backup function
backup() {
    if [ -z "$1" ]; then
        echo "Usage: backup <file>"
        return 1
    fi
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
    echo "✅ Backed up $1"
}

# Extract archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     unrar x "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find text in files (uses ripgrep)
findtext() {
    if [ -z "$1" ]; then
        echo "Usage: findtext <text> [path]"
        return 1
    fi
    rg "$1" "${2:-.}"
}

export N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Profile ZSH startup time (uncomment for debugging)
# zmodload zsh/zprof
# source $ZSH/oh-my-zsh.sh
# zprof

# These plugins are already loaded by Oh My Zsh, no need to source again

eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

# Interactive navigation, fuzzy history/completion, and prompt integrations.
if [[ -o interactive ]]; then
    if (( $+commands[zoxide] )); then
        eval "$(zoxide init zsh)"
    fi

    if (( $+commands[fzf] )) && [[ -t 0 && -o zle ]]; then
        export FZF_DEFAULT_OPTS='--height=45% --layout=reverse --border --info=inline'
        source <(fzf --zsh)
    fi

    if (( $+commands[starship] )); then
        eval "$(starship init zsh)"
    fi
fi



# Claude CLI
if [ -x "$HOME/.claude/local/claude" ]; then
    alias claude="_load_nvm && $HOME/.claude/local/claude"
fi

# Tailscale
if [ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]; then
    alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi

if [[ -o interactive ]]; then
    chonk_key="$(security find-generic-password -a "$USER" -s CHONK_API_KEY -w 2>/dev/null)"
    [[ -n "$chonk_key" ]] && export CHONK_API_KEY="$chonk_key"
    unset chonk_key
fi


# kitty terminal: kittens are only useful inside kitty itself.
if [[ "$TERM" == "xterm-kitty" ]]; then
    alias ssh="kitten ssh"      # copies terminfo to the remote host automatically
    alias icat="kitten icat"    # inline images
    alias kdiff="kitten diff"   # side-by-side diff with images
fi

# User-local command-line tools
export PATH="/Users/thomas/.local/bin:$PATH"
