#!/bin/bash

. vars.sh

echo "Check for installed git"
# for ubuntu
# apt list --installed | grep git > /dev/null

# for alpine
apk update > /dev/null
apk info -vv | grep git > /dev/null

if [ $? -eq 1 ]; then
    # for ubuntu
    # apt install git

    # for alpine
    apk add git
else
    echo "Git already installed"
fi

echo "Check for installed podman"
# for ubuntu
# apt install git
# apt list --installed | grep -i podman > /dev/null

# for alpine
apk info -vv | grep -i podman > /dev/null

if [ $? -eq 1 ]; then
    # for ubuntu
    # apt -y install podman

    # for alpine
    apk add podman
else
    echo "Podman already installed"
fi

# git clone nix-config repo
ls | grep -i nix-configurations > /dev/null
if [ $? -eq 1 ]; then
    git clone $url
else
    cd nix-configurations && git pull && cd ..
fi

podman build --arch=arm64 --build-arg output_format=sd-aarch64 -f Dockerfile ./nix-configurations