#!/usr/bin/env bash

add-wsl-conf() {
    echo "* Copy wsl.conf"
    sudo tee -a /etc/wsl.conf > /dev/null <<EOF
[network]
generateResolvConf = false
EOF
}

set-resolv() {
    echo "* Add nameserver"
    echo "nameserver 223.5.5.5" | sudo tee -a /etc/resolv.conf > /dev/null
}

finish() {
    echo "Use cmd/powershell to excute 'wsl --shutdown'"
    echo "Then restart WSL."
}

add-wsl-conf
set-resolv
finish