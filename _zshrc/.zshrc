# Starship path
export STARSHIP_BIN="$HOME/.starship/bin"

# Pnpm path
export PNPM_HOME="/Users/winglim/Library/pnpm"

# Pyenv
export PYENV_ROOT="${PYENV_ROOT:=${HOME}/.pyenv}"

# Go path
export GOROOT="$HOME/.go"
export GOPATH="$HOME/go"

# Deno path
export DENO_INSTALL="$HOME/.deno"

export PATH="$STARSHIP_BIN:$PNPM_HOME:$DENO_INSTALL/bin:$GOROOT/bin:$GOPATH/bin:$PYENV_ROOT/bin:$PATH"

# Initialize Starship
eval "$(starship init zsh)"

# Plugins

## https://github.com/zsh-users/zsh-autosuggestions
source $HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
## https://github.com/zdharma/fast-syntax-highlighting
source $HOME/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
## https://github.com/zsh-users/zsh-completions
fpath=($HOME/.zsh/plugins/zsh-completions/src $fpath)
autoload -U compinit && compinit
## https://github.com/skywind3000/z.lua
eval "$(lua $HOME/.zsh/plugins/z/z.lua --init zsh)"

# Shortcuts

## Git shortcuts
alias gst="git status"
alias gcmsg="git commit -m"
alias gp="git push"
alias ga="git add"
alias gaa="git add --all"

## Vim shortcuts
alias vim=nvim

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

# Extract archives
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
