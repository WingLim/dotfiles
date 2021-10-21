# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(
	fast-syntax-highlighting
	zsh-autosuggestions
	zsh-z
	zsh-completions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Go root and path
export GOROOT="$HOME/.go"
export GOPATH="$HOME/go"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"

export PYENV_ROOT="${PYENV_ROOT:=${HOME}/.pyenv}"

export PATH="$GOROOT/bin:$GOPATH/bin:$PYENV_ROOT/bin:$PNPM_HOME:$PATH"

# Lazyload Function

## Setup a mock function for lazyload
_lazyload_add_command() {
    eval "$1() { \
        unfunction $1; \
        _lazyload_command_$1; \
        $1 \$@; \
    }"
}

## Setup autocompletion for lazyload
_lazyload_add_completion() {
    local comp_name="_lazyload__compfunc_$1"
    eval "${comp_name}() { \
        compdef -d $1; \
        _lazyload_completion_$1; \
    }"
    compdef $comp_name $1
}

## Lazyload thefuck
if (( $+commands[thefuck] )) &>/dev/null; then
    _lazyload_command_fuck() {
        eval $(thefuck --alias)
    }

    _lazyload_add_command fuck
fi

## Lazyload pyenv
if (( $+commands[pyenv] )) &>/dev/null; then
    export PATH="${PYENV_ROOT}/shims:${PATH}"

    _lazyload_command_pyenv() {
        eval "$(command pyenv init -)"
        eval "$(command pyenv virtualenv-init -)"
    }

    _lazyload_completion_pyenv() {
        source "${HOME}/.pyenv/completions/pyenv.zsh"
    }

    _lazyload_add_command pyenv
    _lazyload_add_completion pyenv
fi

## Lazyload goenv
if (( $+commands[goenv] )) &>/dev/null; then
    export PATH="${GOENV_ROOT}/shims:${PATH}"

    _lazyload_command_goenv() {
        eval "$(goenv init -)"
    }

    _lazyload_completion_goenv() {
        source "$GOENV_ROOT/completions/goenv.zsh"
    }

    _lazyload_add_command goenv
    _lazyload_add_completion goenv
fi

alias vim=nvim
alias vi=nvim

# Git shortcuts
alias gst="git status"
alias gcmsg="git commit -m"
alias gp="git push"
alias ga="git add"
alias gaa="git add --all"
# Git Undo
alias git-undo="git reset --soft HEAD^"

git-config() {
    echo "* Git Configuration"
    echo -n "Please input Git Username:"
    read username
    
    echo -n "Please input Git Email:"
    read email

    echo "Done!"

	git config --global user.name "${username}"
	git config --global user.email "${email}"
}

extract() {
    if [[ -f $1 ]]; then
        case $1 in
        *.tar.bz2) tar xjf $1 ;;
        *.tar.gz) tar xzf $1 ;;
        *.tar.xz) tar xf $1 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) unrar e $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 ;;
        *.tbz2) tar xjf $1 ;;
        *.tgz) tar xzf $1 ;;
        *.zip) unzip "$1" ;;
        *.Z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
