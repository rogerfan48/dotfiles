# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# SEC: oh-my-zsh config
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"
ZSH_THEME="powerlevel10k/powerlevel10k"

HYPHEN_INSENSITIVE="true" # Case-sensitive completion must be off. _ and - will be interchangeable.
# DISABLE_UNTRACKED_FILES_DIRTY="true" # disable marking untracked files, make large repo's status check much faster

# To make oh-my-zsh can load the plugins
# NOTE: suffix need to be `.plugin.zsh` to make oh-my-zsh load plugins
# a-MacOS: `ln -s $(brew --prefix)/share/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions`
# a-Linux: `ln -s /usr/share/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions`
# b-MacOS: `ln -s`$(brew --prefix)/share/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting`
# b-Linux: `source /usr/share/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting`
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# SEC: zsh config
HISTFILE=~/.zsh_history
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=10000
SAVEHIST=10000
setopt append_history     # append instead of overwrite to history
setopt inc_append_history # add commands to history file immediately
setopt share_history      # share history among multiple terminal
setopt hist_ignore_dups   # ignore consecutive duplicate commands
setopt hist_reduce_blanks # don't record redundant space in the command history
setopt hist_find_no_dups  # don't show duplicate when using Ctrl+R

bindkey '^[[OPT-RIGHT]' forward-word # Alt-Right
bindkey '^[[OPT-LEFT]' backward-word # Alt-Left
bindkey '^[[OPT-BACKSPACE]' backward-kill-word
bindkey '^[[CMD-BACKSPACE]' backward-kill-line

export LANG=en_US.UTF-8 # !!! zh_TW.UTF-8

alias vim=nvim

# SEC: Plugins config
ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=1,bold #red,bold
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=205 #207
# ZSH_HIGHLIGHT_STYLES[alias]=fg=2 #083
# ZSH_HIGHLIGHT_STYLES[builtin]=fg=2 #083
# ZSH_HIGHLIGHT_STYLES[function]=fg=2 #083
# ZSH_HIGHLIGHT_STYLES[command]=fg=2 #083
# ZSH_HIGHLIGHT_STYLES[precommand]=fg=2,underline #083
ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=205 #207
ZSH_HIGHLIGHT_STYLES[hashed-command]=fg=205 #207
ZSH_HIGHLIGHT_STYLES[path]=fg=4,underline #087
ZSH_HIGHLIGHT_STYLES[globbing]=none
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=141
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=141
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=fg=141
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=3 #228
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=3 #228 
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=80
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=80
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=80
ZSH_HIGHLIGHT_STYLES[redirection]=fg=80
ZSH_HIGHLIGHT_STYLES[assign]=fg=80

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=242

# SEC: Extensions config

# add Neovim Mason bin into $PATH
MASON_BIN="$HOME/.local/share/nvim/mason/bin"
echo "$PATH" | grep -q "$MASON_BIN" || export PATH="$MASON_BIN:$PATH"

alias bat="bat --paging never" # To prevent using paging when many lines
source <(fzf --zsh) # Set up fzf key bindings and fuzzy completion

# SEC: Custom functions
function path_prepend() {
  if [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

function mysass() {
    # if only 1 argu: compile ${1}/scss/style.scss to ${1}/css/style.min.css in compressed mode
    # if have 2 augu: just compile ${1} to ${2} in compressed mode
    if [ -z $2 ]
    then
        sass -w -s 'compressed' --no-source-map --verbose ${1}/scss/style.scss:${1}/css/style.min.css
    else
        sass -w -s 'compressed' --no-source-map --verbose $1:$2
    fi
}

function mytree() {
    # to print out zh_TW instead of <?>
    # just use it as usual
    tree -N $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}
}

function kb() {
    echo "current jobs:"
    jobs
    read "userInput?Are You Sure To Kill Jobs from 1 to 10? (y/n): "
    if [[ "$userInput" == "y" || "$userInput" == "Y" ]]; then
        kill %1 %2 %3 %4 %5 %6 %7 %8 %9 %10
        echo "successfully killed jobs from 1 to 10!"
    elif [[ "$userInput" == "n" || "$userInput" == "N" ]]; then
        echo "Operation Canceled."
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
}

# SEC: RUBY
if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  path_prepend "/opt/homebrew/opt/ruby/bin"
  path_prepend "`gem environment gemdir`/bin"
fi

# SEC: Google Cloud SDK
# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# SEC: Flutter pub global
path_prepend "$HOME/.pub-cache/bin"

# SEC: NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# SEC: CONDA
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh # NOTE: Stay at the bottom of .zshrc
