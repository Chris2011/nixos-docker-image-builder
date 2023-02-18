#!/bin/bash

echo "Check for installed git"
apt list --installed | grep git > /dev/null

if [ $? -eq 1 ]; then
    apt install git
else
    echo "Git already installed"
fi

echo "Check for installed podman"
apt list --installed | grep -i podman > /dev/null

if [ $? -eq 1 ]; then
    apt -y install podman
else
    echo "Podman already installed"
fi

# git clone nix-config repo
ls | grep -i nix-configurations > /dev/null
if [ $? -eq 1 ]; then
    git clone https://github.com/Chris2011/nix-configurations.git
else
    cd nix-configurations && git pull && cd ..
fi

podman build --build-arg output_format=sd-aarch64 -f Dockerfile ./nix-configurations