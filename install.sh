#!/usr/bin/env bash

check-system() {
    if [ "$(uname)" == "Darwin" ]; then
        if ! [ -x "$(command -v brew)" ]; then
            echo "* Installing Homebrew"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        fi
        export INSTALLER="brew install"
        export OS="Darwin"
    elif [ -x "$(command -v apt-get)" ]; then
        export INSTALLER="sudo apt-get install -y"
        export OS="Ubuntu"
    elif [ -x "$(command) -v pacman" ]; then
        export INSTALLER="sudo pacman -S --noconfirm"
        export OS="Manjaro"
    fi
}

clone-repo() {
    echo "* Cloning WingLim/dotfiles"
    
    git clone https://github.com/WingLim/dotfiles "$HOME/dotfiles"
    rm -rf "$HOME/dotfiles/.git"
}

install-package() {
    __pkg_to_be_installed=(
        zsh
        wget
        git
        tree
        neofetch
        neovim
    )

    for __pkg in "${__pkg_to_be_installed[@]}"; do
        $INSTALLER "$__pkg"
    done
}

install-node() {
    case "$OS" in
        "Darwin")
            $INSTALLER node
        ;;
        "Ubuntu")
            curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
            $INSTALLER nodejs
        ;;
        "Manjaro")
            $INSTALLER nodejs npm
        ;;
        *)
            echo "Unsupport OS"
        ;;
    esac
    
}

setup-omz() {
    echo "* Installing Oh-My-Zsh"
    curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash
    echo "* Installing ZSH Plugins & Themes:"
    echo "  - zsh-autosuggestions"
    echo "  - zsh-completions"
    echo "  - zsh-z"
    echo "  - fast-syntax-highlighting"
    echo "  - powerlevel10k zsh-theme"


    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions"
    git clone https://github.com/agkozak/zsh-z "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-z"
    git clone https://github.com/zdharma/fast-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting"
    
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
}

install-pyenv() {
    echo "* Installing pyenv"
    local GITHUB="https://github.com"
    local PYENV_ROOT="$HOME/.pyenv"
    git clone "${GITHUB}/pyenv/pyenv.git"            "${PYENV_ROOT}"
    git clone "${GITHUB}/pyenv/pyenv-doctor.git"     "${PYENV_ROOT}/plugins/pyenv-doctor"
    git clone "${GITHUB}/pyenv/pyenv-installer.git"  "${PYENV_ROOT}/plugins/pyenv-installer"
    git clone "${GITHUB}/pyenv/pyenv-update.git"     "${PYENV_ROOT}/plugins/pyenv-update"
    git clone "${GITHUB}/pyenv/pyenv-virtualenv.git" "${PYENV_ROOT}/plugins/pyenv-virtualenv"
    git clone "${GITHUB}/pyenv/pyenv-which-ext.git"  "${PYENV_ROOT}/plugins/pyenv-which-ext"
}

install-goenv() {
    echo "* Installing syndbg/goenv"

    git clone https://github.com/syndbg/goenv.git "$HOME/.goenv"
}

install-thinkvim() {
    git clone --depth=1 https://github.com/hardcoreplayers/ThinkVim.git ~/.config/nvim
    cd ~/.config/nvim || return
    pyenv virtualenv 3.9.0 neovim
    bash scripts/install.sh
}

clash-proxy() {
    echo "* Setting clash proxy"
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
    echo "* Import .zshrc"
    cat "$HOME/dotfiles/_zshrc/.zshrc" > "$HOME/.zshrc"
    cat "$HOME/dotfiles/p10k/.p10k.zsh" > "$HOME/.p10k.zsh"
    chsh -s /bin/zsh
    # shellcheck source=/dev/null
    source "$HOME/.zshrc"
}

install-python() {
    pyenv install 3.9.0
    pyenv global 3.9.0
}

finish() {
    echo "* Clean up..."
    rm -rf "$HOME/dotfiles"
}

check-system
install-package
install-node
clone-repo
setup-omz
install-pyenv
install-goenv
zshrc
install-python
install-thinkvim
clash-proxy
finish
