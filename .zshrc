# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# To make oh-my-zsh can load the plugins
# It need `ln -s $(brew --prefix)/share/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions`
#      or `ln -s /usr/share/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions`
plugins=(git zsh-autosuggestions)

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

source $ZSH/oh-my-zsh.sh
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $HOME/p10k.zsh ]] || source $HOME/.p10k.zsh

source /Users/roger/.rogerrc
