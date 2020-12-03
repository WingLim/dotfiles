#!/usr/bin/env bash

check-system() {
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
    elif [ -x "$(command) -v pacman" ]; then
        INSTALLER="sudo pacman -S --noconfirm"
        OS="Manjaro"
    fi
}

set-system() {
    case "$OS" in
        "Darwin")
            NODE_NAME="node"
            ccls-platform="apple-darwin"
            $INSTALLER update
        ;;
        "Ubuntu")
            curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
            NODE_NAME="nodejs"
            ccls-platform="linux-gnu-ubuntu-20.04"
            export DEBIAN_FRONTEND=noninteractive
            $INSTALLER update
        ;;
        "Manjaro")
            NODE_NAME="nodejs npm"
            ccls-platform="linux-gnu-ubuntu-20.04"
            $INSTALLER -u
        ;;
        *)
            echo "Unsupport OS"
        ;;
    esac
}

clone-repo() {
    hint "* Cloning WingLim/dotfiles"
    
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
        "$NODE_NAME"
        cmake
        gcc
        clang

        # for python
        libreadline-dev
        libbz2-dev
        libffi-dev
        libgdbm-dev
        libsqlite3-dev
        libssl-dev
        zlib1g-dev
    )

    for __pkg in "${__pkg_to_be_installed[@]}"; do
        $INSTALLER "$__pkg"
    done
}

setup-omz() {
    hint "* Installing Oh-My-Zsh"
    curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash
    hint "* Installing ZSH Plugins & Themes:"
    hint "  - zsh-autosuggestions"
    hint "  - zsh-completions"
    hint "  - zsh-z"
    hint "  - fast-syntax-highlighting"
    hint "  - powerlevel10k zsh-theme"


    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions"
    git clone https://github.com/agkozak/zsh-z "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-z"
    git clone https://github.com/zdharma/fast-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting"
    
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
}

install-pyenv() {
    hint "* Installing pyenv"
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
}

install-goenv() {
    hint "* Installing syndbg/goenv"

    git clone https://github.com/syndbg/goenv.git "$HOME/.goenv"
}

install-thinkvim() {
    mkdir -p "$HOME/.npm-global"
    git clone --depth=1 https://github.com/hardcoreplayers/ThinkVim.git ~/.config/nvim
    npm install -g yarn
    pyenv virtualenv 3.9.0 neovim
    mkdir -p "$HOME/.thinkvim.d"
    cat "$HOME/dotfiles/thinkvim/plugins.yaml" > "$HOME/.thinkvim.d/plugins.yaml"
    cd ~/.config/nvim || exit
    echo y | bash scripts/install.sh
    yarn global add \
        dockerfile-language-server-nodejs \
        bash-language-server intelephense
}

install-ccls() {
    hint "* Installing ccls"
    if ! [ -x "$(command -v ccls)" ]; then
        mkdir -p "$HOME/src" && cd "$HOME/src" || exit
        llvm-url=https://mirrors.tuna.tsinghua.edu.cn/github-release/llvm/llvm-project/LLVM%2011.0.0/clang+llvm-11.0.0-x86_64-"${ccls-platform}".tar.xz
        wget "${llvm-url}" && tar -xf clang+llvm-11.0.0-x86_64-"${ccls-platform}".tar.xz
        git clone --depth=1 --recursive https://github.com/MaskRay/ccls
        cd ccls || exit
        cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$HOME/src/clang+llvm-11.0.0-x86_64-${ccls-platform}"
        cmake --build Release
    fi
}

clash-proxy() {
    hint "* Setting clash proxy"
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
    hint "* Import .zshrc"
    cat "$HOME/dotfiles/_zshrc/.zshrc" > "$HOME/.zshrc"
    cat "$HOME/dotfiles/p10k/.p10k.zsh" > "$HOME/.p10k.zsh"
    chsh -s /bin/zsh
    # shellcheck source=/dev/null
    source "$HOME/.zshrc"
}

install-python() {
    hint "* Installing python 3.9.0"
    pyenv -v
    pyenv install 3.9.0
    pyenv global 3.9.0
}

finish() {
    hint "* Clean up..."
    rm -rf "$HOME/dotfiles"
}

hint() {
    echo -e "\033[32m$1\033[0m"
}

check-system
set-system
install-package
clone-repo
setup-omz
install-pyenv
install-goenv
zshrc
install-python
install-thinkvim
install-ccls
clash-proxy
finish
