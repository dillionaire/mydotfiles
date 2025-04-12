# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme for Oh My Zsh
ZSH_THEME="af-magic"

# Plugins
plugins=(git vscode z zsh-autosuggestions zsh-syntax-highlighting)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load homebrew path
export PATH="/opt/homebrew/bin:$PATH"

# Golang environment variables
export GOROOT=$(brew --prefix go)/libexec
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH"

# Avoid duplicate PATH entries
PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '!a[$1]++' | sed 's/:$//')

# Use compinit caching for faster shell initialization
autoload -Uz compinit && compinit -i

# Ensure that NVM is correctly installed and sourced
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Check if 'fabric' is installed
if ! command -v fabric &> /dev/null; then
    echo "Warning: 'fabric' is not installed or not in PATH"
fi

# Base directory for Obsidian notes
obsidian_base="${OBSIDIAN_BASE:-$HOME/Code/obsidian}"
if [ ! -d "$obsidian_base" ]; then
    echo "Warning: Obsidian base directory does not exist at $obsidian_base"
fi

# Dynamically define functions based on pattern files in a specific directory
if [ -d ~/.config/fabric/patterns ] && [ "$(ls -A ~/.config/fabric/patterns)" ]; then
    for pattern_file in ~/.config/fabric/patterns/*; do
        pattern_name=$(basename "$pattern_file")
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
    done
fi

# Define a shortcut for fabric commands with YouTube links
yt() {
    local video_link="$1"
    fabric -y "$video_link" --transcript
}

# Aliases
alias zshconfig="code ~/.zshrc"
alias ll="ls -la"

# OS-specific aliases
case "$(uname)" in
    Linux)
        alias update="sudo apt update && sudo apt upgrade -y"
        ;;
    Darwin)
        alias update="brew update && brew upgrade"
        ;;
esac

export N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Profile ZSH startup time (uncomment for debugging)
# zmodload zsh/zprof
# source $ZSH/oh-my-zsh.sh
# zprof


# Ensure zsh-syntax-highlighting
source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
