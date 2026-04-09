export ZSH="$HOME/.oh-my-zsh"
export PATH="/opt/homebrew/bin:$PATH"
export TERM=xterm-256color

ZSH_THEME="spaceship"

autoload -Uz compinit
compinit

_makefile_targets() {
  local -a targets
  targets=(
    $(make -qp 2>/dev/null \
      | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ && !/^Makefile/ {print $1}' \
      | sort -u)
  )
  compadd $targets
}

compdef _makefile_targets make

zstyle ':omz:update' mode auto      # update automatically without asking

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  exec_time     # Execution time
  line_sep      # Line break
  node
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
SPACESHIP_USER_SHOW=always
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SUFFIX=" "

# Alias

## Hermes

alias dani="hermes"

## general

alias vim=nvim
alias pip="pip3"

## shell

alias c="clear"
function cmkd(){
  mkdir "$1"
  cd "$1"
}

function lsg(){
  ls | grep "$1"
}

function lsr(){
  ls -R | grep "$1"
}

## git

alias g="git"
alias gs="git status -s"

alias git-personal="git config user.name ‘VitorLostadaC’ && git config user.email ‘vitorlostada@hotmail.com‘"

function ga() {
    if [ -z "$1" ]; then
        git add .
    else
        git add "$1"
    fi
}

(( ${+aliases[gc]} )) && unalias gc
function gc() {
    local message="$*"
    git commit -m "$message"
}

## ai

function ai(){
  if [ -z "$1" ]; then
    echo "Usage: ai <message>"
    return 1
  fi

  sgpt "$*"

}  

## tmux 

alias t="tmux"
alias ts="tmux list-sessions"
alias tk="tmux kill-session -t"

function tn(){
	tmux new-session -s "$1"
}

## zoxide

function find_dir() {
    if [ -z "$1" ]; then
        echo "Usage: $2 <query>"
        return 1
    fi

    local dir
    dir=$(zoxide query -i "$1")

    if [ -z "$dir" ]; then
        echo "No matching directory found for query: $1"
        return 1
    fi

    echo "$dir"
}

## Function to open the directory in Visual Studio Code
function zc() {
    local dir
    dir=$(find_dir "$1" "zcode")

    if [ $? -eq 0 ]; then
        cursor "$dir"
    fi
}

## Function to open the directory in Vim
function zv() {
    local dir
    dir=$(find_dir "$1" "zcode")

    if [ $? -eq 0 ]; then
        cd "$dir" || return
        vim .
    fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/vitorlostada/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/vitorlostada/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/vitorlostada/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/vitorlostada/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# pnpm
export PNPM_HOME="/Users/vitorlostada/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

eval $(thefuck --alias)
eval "$(zoxide init zsh)"

# bun completions
[ -s "/Users/vitorlostada/.oh-my-zsh/completions/_bun" ] && source "/Users/vitorlostada/.oh-my-zsh/completions/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# tmux

export TMUX_CONF="$HOME/.config/tmux/tmux.conf"

if command -v tmux &> /dev/null && tmux info &> /dev/null; then
  tmux source-file "$TMUX_CONF"
fi

        export ANDROID_HOME="/Users/vitorlostada/Library/Android/sdk" 

. "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

# Duplicate git repository excluding ignored files
# Usage: duplicate-repo [source-dir] [dest-name]
# Example: duplicate-repo . mono-repo-law
function duplicate-repo() {
    local source_dir="${1:-.}"
    local dest_name="${2}"
    
    if [ -z "$dest_name" ]; then
        echo "Usage: duplicate-repo [source-dir] <dest-name>"
        echo "Example: duplicate-repo . mono-repo-law"
        return 1
    fi
    
    # Get absolute path of source directory
    local source_abs=$(cd "$source_dir" && pwd)
    local source_parent=$(dirname "$source_abs")
    local dest_path="$source_parent/$dest_name"
    
    # Check if source is a git repository
    if [ ! -d "$source_abs/.git" ]; then
        echo "Error: $source_dir is not a git repository"
        return 1
    fi
    
    # Check if destination already exists
    if [ -d "$dest_path" ]; then
        echo "Error: Destination $dest_path already exists"
        return 1
    fi
    
    # Create destination directory and copy files
    echo "Duplicating repository from $source_abs to $dest_path..."
    mkdir -p "$dest_path"
    cd "$source_abs" && git archive HEAD | tar -x -C "$dest_path"
    
    if [ $? -eq 0 ]; then
        echo "✓ Successfully duplicated repository to $dest_path"
    else
        echo "✗ Failed to duplicate repository"
        return 1
    fi
}

# opencode
export PATH=/Users/vitorlostada/.opencode/bin:$PATH
