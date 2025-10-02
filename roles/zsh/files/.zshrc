# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
#
export PATH=$HOME/.local/bin:$PATH

setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt interactivecomments                                      # Allow comments in interactive prompts

setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.

# Path to your oh-my-zsh installation.
export ZSH="/home/andrew/.oh-my-zsh"

plugins=(ssh-agent zsh-syntax-highlighting zsh-autosuggestions kubectl)

zstyle :omz:plugins:ssh-agent agent-forwarding yes

source $ZSH/oh-my-zsh.sh

alias gitcleanup="git fetch -p && git branch -vv | grep 'origin/.*: gone]' | awk '{print \$1}' | xargs git branch -D"
alias vim="nvim"
alias k="kubectl"
alias kns="kubens"
alias kctx="kubectx"

wt() {
  _wt_setup() {
    local worktree_path="$1"
    local git_root="$2"

    # Copy .env from main branch if available, otherwise use .env.example
    local main_env="${git_root}/main/.env"
    local env_example="${git_root}/.env.example"
    [[ ! -f "$env_example" ]] && env_example="${worktree_path}/.env.example"

    if [[ -f "$main_env" ]]; then
      echo "Copying .env from main branch..."
      cp "$main_env" "${worktree_path}/.env"
    elif [[ -f "$env_example" ]]; then
      echo "Copying .env.example to .env..."
      cp "$env_example" "${worktree_path}/.env"
    fi

    if [[ -f "${worktree_path}/package.json" ]]; then
      echo "Installing npm dependencies..."
      (cd "${worktree_path}" && npm install)
    fi

    echo "✓ Worktree ready at: ${worktree_path}"
    cd "${worktree_path}"
  }

  case "$1" in
    "")
      # Interactive worktree switcher with fzf
      local selected=$(git worktree list | grep -v '(bare)' | fzf --height=40% --reverse --border | awk '{print $1}')
      if [[ -n "$selected" ]]; then
        cd "$selected"
      fi
      ;;

    add)
      if [[ -z "$2" ]]; then
        echo "Usage: wt add <branch-name> [base-branch]"
        return 1
      fi

      local branch_name="$2"
      local base_branch="${3:-main}"
      local git_root=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)

      if [[ -z "$git_root" ]]; then
        echo "Error: Not in a git repository"
        return 1
      fi

      local worktree_path="${git_root}/${branch_name}"

      # Check if worktree already exists
      if git worktree list | grep -q "${worktree_path}"; then
        echo "Worktree '${branch_name}' already exists, switching to it..."
        cd "${worktree_path}"
        return 0
      fi

      # Check if branch already exists
      if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
        echo "Branch '${branch_name}' already exists, creating worktree from existing branch..."
        git worktree add "${worktree_path}" "${branch_name}" || return 1
      else
        echo "Creating worktree for branch '${branch_name}' from '${base_branch}'..."
        git worktree add -b "${branch_name}" "${worktree_path}" "${base_branch}" || return 1
      fi

      _wt_setup "${worktree_path}" "${git_root}"
      ;;

    pr)
      if [[ -z "$2" ]]; then
        echo "Usage: wt pr <pr-number>"
        return 1
      fi

      local pr_number="$2"
      local branch_name="pr-${pr_number}"
      local git_root=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)

      if [[ -z "$git_root" ]]; then
        echo "Error: Not in a git repository"
        return 1
      fi

      local worktree_path="${git_root}/${branch_name}"

      echo "Fetching PR #${pr_number}..."
      git fetch origin "pull/${pr_number}/head:${branch_name}" || return 1

      echo "Creating worktree for PR #${pr_number}..."
      git worktree add "${worktree_path}" "${branch_name}" || return 1

      _wt_setup "${worktree_path}" "${git_root}"
      ;;

    remove|rm)
      if [[ -z "$2" ]]; then
        echo "Usage: wt remove <branch-name>"
        return 1
      fi

      local branch_name="$2"
      local git_root=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)

      if [[ -z "$git_root" ]]; then
        echo "Error: Not in a git repository"
        return 1
      fi

      local worktree_path="${git_root}/${branch_name}"
      local current_worktree=$(git rev-parse --path-format=absolute --show-toplevel 2>/dev/null)

      # If we're in the worktree we're trying to remove, cd to bare repo first
      if [[ "$current_worktree" == "$worktree_path" ]]; then
        echo "Leaving worktree..."
        cd "${git_root}"
      fi

      # Remove worktree if it exists
      if git worktree list | grep -q "${worktree_path}"; then
        echo "Removing worktree '${branch_name}'..."
        git worktree remove "${worktree_path}" || git worktree remove --force "${worktree_path}"
      fi

      # Delete branch if it exists
      if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
        echo "Deleting branch '${branch_name}'..."
        git branch -D "${branch_name}"
      fi
      ;;

    *)
      git worktree "$@"
      ;;
  esac
}

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-r

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY_TIME  # Multiple sessions contribute to a shared history
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

WORDCHARS=${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/usr/local/bin/aws_completer' aws

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

source ~/.zsh_profile

eval "$(starship init zsh)"
