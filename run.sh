#!/bin/bash
# https://www.shellcheck.net/
set -e

cat /proc/cpuinfo

EXIT_CODE=0

. "${GITHUB_WORKSPACE}/vars.sh"

echo "Check for installed git"
git --version > /dev/null || EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    # for debian or ubuntu
    apt update
    apt -y install git

    # for alpine
    # apk add git
else
    echo "Git already installed"
fi

echo "Check for installed podman/docker"
# podman --version > /dev/null || EXIT_CODE=$?
docker --version > /dev/null || EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    # for debian or ubuntu
    # apt -y install podman
    apt -y install docker

    # for alpine
    # apk add podman
else
    echo "Podman/Docker already installed"
fi

# git clone nix-config repo
ls ${GITHUB_WORKSPACE}/*nix-configurations* > /dev/null || EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    git clone "$url" "${GITHUB_WORKSPACE}/nix-configurations" > /dev/null
else
    cd nix-configurations && git pull && cd ..
fi

# podman build --arch arm64 --build-arg output_format=sd-aarch64 -f Dockerfile ${GITHUB_WORKSPACE}/nix-configurations
docker build --build-arg output_format=sd-aarch64 -f Dockerfile ${GITHUB_WORKSPACE}/nix-configurations