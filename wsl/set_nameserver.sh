#!/usr/bin/env bash

add-wsl-conf() {
    echo "* Generate wsl.conf"
    sudo tee /etc/wsl.conf > /dev/null <<EOF
[network]
generateResolvConf = false
EOF
}

set-resolv() {
    echo "* Add nameserver"
    if [ -z "$1" ]; then
        local nameserver="223.5.5.5"
    else
        local nameserver=$1
    fi
    
    echo "nameserver $nameserver" | sudo tee /etc/resolv.conf > /dev/null
}

finish() {
    echo "Use cmd/powershell to excute 'wsl --shutdown'"
    echo "Then restart WSL."
}

add-wsl-conf
set-resolv "$1"
finish