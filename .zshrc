# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme for Oh My Zsh
# Theme disabled — using Starship prompt instead
ZSH_THEME=""

# Plugins
plugins=(git vscode z zsh-autosuggestions fast-syntax-highlighting)

# Load Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# Load homebrew path
export PATH="/opt/homebrew/bin:$PATH"

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Default editor
export EDITOR="vim"

# Avoid duplicate PATH entries
PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '!a[$1]++' | sed 's/:$//')

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
alias zshreload="source ~/.zshrc && echo '✅ ZSH config reloaded'"
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"

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

# LM Studio CLI
if [ -d "$HOME/.cache/lm-studio/bin" ]; then
    export PATH="$PATH:$HOME/.cache/lm-studio/bin"
fi


# Claude CLI
if [ -x "$HOME/.claude/local/claude" ]; then
    alias claude="_load_nvm && $HOME/.claude/local/claude"
fi

# Antigravity
if [ -d "$HOME/.antigravity/antigravity/bin" ]; then
    export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
fi
# Tailscale
if [ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]; then
    alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi

# Starship prompt
eval "$(starship init zsh)"
