#!/usr/bin/env bash

# Check system and set installer
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

# Set node package name and update software
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
            fish
            wget
            git
            tree
            neofetch
            neovim
            cmake
            gcc
	        ruby
            lua
        )
    # If not mac, install below lib for compile python
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

install_starship() {
    ok "* Installing Starship"
    mkdir -p "$HOME/.starship/bin"
    sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y -b $HOME/.starship/bin
}

install_asdf() {
    ok "* Installing asdf"
    git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.8.1
    mkdir -p $HOME/.config/fish/completions
    ln -s $HOME/.asdf/completions/asdf.fish $HOME/.config/fish/completions

    asdf_bin=$HOME/.asdf/bin/asdf

    ok "* Installing Nodejs"
    $asdf_bin plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    $asdf_bin install nodejs lts

    ok "*Installing Python"
    $asdf_bin plugin add python https://github.com/danhper/asdf-python.git
    $asdf_bin install python 3.10.0
}

install_deno() {
    ok "* Installing deno"
    curl -fsSL https://deno.land/x/install/install.sh | sh
}

install_spacevim() {
    ok "* Installing SpaceVim"
    if ! [ -d "$HOME/.SpaceVim" ]; then
        curl -sLf https://spacevim.org/install.sh | bash
    else 
        warn "! SpaceVim already installed"
    fi
}

# Add function for shell enable clash proxy
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
    noproxy
    export ALL_PROXY="http://\$CLASH_IP:7890"
    echo "ProxyCommand nc -X 5 -x \$CLASH_IP:7890 %h %p" >> ~/.ssh/config
    echo "Set proxy"
}

noproxy() {
    unset ALL_PROXY
    sed '/ProxyCommand/d' ~/.ssh/config > ~/.ssh/config.bk && mv ~/.ssh/config.bk ~/.ssh/config
    echo "Unset proxy"
}
EOF
}

import_fish_config() {
    ok "* Import fish config"
    cat "$HOME/dotfiles/fish/config.fish" > "$HOME/.config/fish/config.fish"
}

cleanup() {
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
install_starship
install_deno
install_asdf
install_spacevim
clone_repo
import_fish_config
if ! [ "$noproxy" == 1 ]; then
    clash_proxy
fi
cleanup
