export ZSH="$HOME/.oh-my-zsh"
export PATH="/opt/homebrew/bin:$PATH"
export TERM=xterm-256color

ZSH_THEME="spaceship"


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

alias vim=nvim

alias c="clear"

alias t="tmux"
alias ga="git add ."
alias gs="git status -s"
alias pip="pip3"

function tn(){
	tmux new-session -s "$1"
}

function gc() {
    local message="$*"
    git commit -m "$message"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
PATH=~/.console-ninja/.bin:$PATH

eval "$(zoxide init zsh)"

function zc() {
    if [ -z "$1" ]; then
        echo "Usage: zcode <query>"
        return 1
    fi

    # Use zoxide to find the directory
    local dir
    dir=$(zoxide query -i "$1")

    if [ -z "$dir" ]; then
        echo "No matching directory found for query: $1"
        return 1
    fi

    # Open the directory in Visual Studio Code
    cursor "$dir"
}


function zv() {
    if [ -z "$1" ]; then
        echo "Usage: zcode <query>"
        return 1
    fi

    # Use zoxide to find the directory
    local dir
    dir=$(zoxide query -i "$1")

    if [ -z "$dir" ]; then
        echo "No matching directory found for query: $1"
        return 1
    fi

    # Open the directory in Visual Studio Code
    vim "$dir"
}



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
