#!/usr/bin/env bash

# check system and set installer
check_system() {
    if [ "$(uname)" == "Darwin" ]; then
        if ! [ -x "$(command -v brew)" ]; then
            echo "* Installing Homebrew"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        fi
        INSTALLER="brew install"
        OS="Darwin"
    elif [ -x "$(command -v apt-get)" ]; then
        INSTALLER="sudo apt-get install -y"
        OS="Ubuntu"
    elif [ -x "$(command -v pacman)" ]; then
        INSTALLER="sudo pacman -S --noconfirm"
        OS="Manjaro"
    fi
}

# set node package name and update software
set_system() {
    case "$OS" in
        "Darwin")
            brew update
        ;;
        "Ubuntu")
            export DEBIAN_FRONTEND=noninteractive
            sudo apt-get update -y
        ;;
        "Manjaro")
            sudo pacman -Syu --noconfirm
        ;;
        *)
            echo "Unsupport OS"
	    exit
        ;;
    esac
}

clone_repo() {
    ok "* Cloning WingLim/dotfiles"
    
    git clone https://github.com/WingLim/dotfiles.git "$HOME/dotfiles"
    rm -rf "$HOME/dotfiles/.git"
}

install_package() {
    ok "* Installing packages"
    __pkg_to_be_installed=(
            zsh
            wget
            git
            tree
            neofetch
            neovim
            cmake
            gcc
	        ruby
        )
    # if not mac, install below lib for compile python
    if ! [ "$OS" == "Darwin" ];then
        __pkg_to_be_installed+=(
	        # for compile ccls
	        clang
            libreadline-dev
            libbz2-dev
            libffi-dev
            libgdbm-dev
            libsqlite3-dev
            libssl-dev
            zlib1g-dev
        )
    fi

    for __pkg in "${__pkg_to_be_installed[@]}"; do
        $INSTALLER "$__pkg"
    done
}

setup_omz() {
    ok "* Installing Oh-My-Zsh"
    if ! [ -d "$HOME/.oh-my-zsh" ]; then
        curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash
        ok "* Installing ZSH Plugins & Themes:"
        ok "  - zsh-autosuggestions"
        ok "  - zsh-completions"
        ok "  - zsh-z"
        ok "  - fast-syntax-highlighting"
        ok "  - powerlevel10k zsh-theme"


        git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
        git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions"
        git clone https://github.com/agkozak/zsh-z "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-z"
        git clone https://github.com/zdharma/fast-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting"
        
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    else
        warn "! Oh-My-Zsh already installed"
    fi
}

install_pyenv() {
    ok "* Installing pyenv"
    if ! [ -d "$HOME/.pyenv" ]; then
        local GITHUB="https://github.com"
        local PYENV_ROOT="$HOME/.pyenv"
        git clone "${GITHUB}/pyenv/pyenv.git"            "${PYENV_ROOT}"
        git clone "${GITHUB}/pyenv/pyenv-doctor.git"     "${PYENV_ROOT}/plugins/pyenv-doctor"
        git clone "${GITHUB}/pyenv/pyenv-installer.git"  "${PYENV_ROOT}/plugins/pyenv-installer"
        git clone "${GITHUB}/pyenv/pyenv-update.git"     "${PYENV_ROOT}/plugins/pyenv-update"
        git clone "${GITHUB}/pyenv/pyenv-virtualenv.git" "${PYENV_ROOT}/plugins/pyenv-virtualenv"
        git clone "${GITHUB}/pyenv/pyenv-which-ext.git"  "${PYENV_ROOT}/plugins/pyenv-which-ext"
        export PYENV_ROOT=$PYENV_ROOT
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
        
        ok "* Installing python 3.10.0"
        pyenv -v
        pyenv install 3.10.0
        pyenv global 3.10.0
    else
        warn "! Pyenv already installed"
    fi
}

install_go() {
    ok "* Installing go"
    wget -q -O - https://git.io/vQhTU | bash
    go version
}

install_pnpm_node() {
    wget -qO- https://get.pnpm.io/install.sh | sh -
    source ~/.bashrc
    pnpm env use --global lts
    pnpm --version
    node --version
}

install_spacevim() {
    ok "* Installing SpaceVim"
    if ! [ -d "$HOME/.SpaceVim" ]; then
        curl -sLf https://spacevim.org/install.sh | bash
    else 
        warn "! SpaceVim already installed"
    fi
}

# add function for shell enable clash proxy
clash_proxy() {
    ok "* Setting clash proxy"
    if [[ $(uname -r) =~ "microsoft" ]]
    then
        local ip="\$(ip route | grep default | awk '{print \$3}')"
    else
        local ip="127.0.0.1"
    fi
    echo "export CLASH_IP=${ip}" >> "$HOME/.zshrc"
    cat >> "$HOME/.zshrc" <<EOF
# Clash proxy for WSL

proxy() {
    export ALL_PROXY="http://\$CLASH_IP:7890"
    echo "ProxyCommand nc -X 5 -x \$CLASH_IP:7890 %h %p >> ~/.ssh/config"
}

noproxy() {
    unset ALL_PROXY
    sed '/ProxyCommand/d' ~/.ssh/config > ~/.ssh/config.bk && mv ~/.ssh/config.bk ~/.ssh/config
}
EOF
}

zshrc() {
    ok "* Import .zshrc"
    cat "$HOME/dotfiles/_zshrc/.zshrc" > "$HOME/.zshrc"
    cat "$HOME/dotfiles/p10k/.p10k.zsh" > "$HOME/.p10k.zsh"
}

finish() {
    ok "* Clean up..."
    rm -rf "$HOME/dotfiles"
    ok "* Please use below command to set default shell"
    ok "chsh -s /bin/zsh"
}

ok() {
    echo -e "\033[32m$1\033[0m"
}

warn() {
    echo -e "\033[33m$1\033[0m"
}

# getopt must have -o, but can set as '' to set NO short option
# otherwise it can not parse long option
ARGS=$(getopt -o '' --long novim,cdn,noproxy -- "$@")
eval set -- "${ARGS}"

while [ -n "$1" ]
do
    case "$1" in
    --noproxy)
        noproxy=1
    ;;
    --)
        shift
        break
    ;;
    esac
shift
done


check_system
set_system
install_package
clone_repo
setup_omz
install_pyenv
install_go
install_pnpm_node
install_spacevim
zshrc
if ! [ "$noproxy" == 1 ]; then
    clash_proxy
fi
finish
