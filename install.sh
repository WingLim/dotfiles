#!/usr/bin/env bash

clone-repo() {
    echo "* Cloning WingLim/dotfiles"
    
    git clone https://github.com/WingLim/dotfiles
    cd "$HOME/dotfiles" || exit
    rm -rf .git
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
    git clone "${GITHUB}/pyenv/pyenv.git"            "${PYENV_ROOT}"
    git clone "${GITHUB}/pyenv/pyenv-doctor.git"     "${PYENV_ROOT}/plugins/pyenv-doctor"
    git clone "${GITHUB}/pyenv/pyenv-installer.git"  "${PYENV_ROOT}/plugins/pyenv-installer"
    git clone "${GITHUB}/pyenv/pyenv-update.git"     "${PYENV_ROOT}/plugins/pyenv-update"
    git clone "${GITHUB}/pyenv/pyenv-virtualenv.git" "${PYENV_ROOT}/plugins/pyenv-virtualenv"
    git clone "${GITHUB}/pyenv/pyenv-which-ext.git"  "${PYENV_ROOT}/plugins/pyenv-which-ext"
}

install-goenv() {
    echo "* Installing syndbg/goenv"

    git clone https://github.com/syndbg/goenv.git ~/.goenv
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
    cat > "$HOME/.zshrc" <<EOF
# Clash proxy for WSL

proxy() {
    export ALL_PROXY="http://\$CLASH_IP:7890"
}

noproxy() {
    unset ALL_PROXY
}
EOF
}

zshrc() {
    echo "* Import .zshrc"
    cat "$HOME/dotfiles/_zshrc/.zshrc" > "$HOME/.zshrc"
    cat "$HOME/dotfiles/p10k/.p10k.zsh" > "$HOME/.p10k.zsh"
}

finish() {
    echo "* Clean up..."
    rm -rf "$HOME/dotfiles"
}

clone-repo
setup-omz
install-pyenv
install-goenv
clash-proxy
zshrc
finish