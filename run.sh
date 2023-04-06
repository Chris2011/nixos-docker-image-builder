#!/bin/bash
# https://www.shellcheck.net/
set -e

. ${GITHUB_WORKSPACE}/vars.sh

echo "Check for installed git"
git --version > /dev/null || true

if [ $? -ne 0 ]; then
    # for debian or ubuntu
    apt update
    apt install git

    # for alpine
    # apk add git
else
    echo "Git already installed"
fi

echo "Check for installed podman"
podman --version > /dev/null || true

if [ $? -ne 0 ]; then
    # for debian or ubuntu
    apt -y install podman

    # for alpine
    # apk add podman
else
    echo "Podman already installed"
fi

# git clone nix-config repo
ls ~/*nix-configurations* > /dev/null
if [ $? -ne 0 ]; then
    git clone "$url" > /dev/null
else
    cd nix-configurations && git pull && cd ..
fi

podman build --arch arm64 --build-arg output_format=sd-aarch64 -f Dockerfile ./nix-configurations