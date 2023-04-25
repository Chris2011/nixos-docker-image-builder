@echo off

REM install WSL
REM say yes to all
REM podman machine init and podman machine start

echo "Check for installed git"
winget list | findstr /i git.git > nul

if %errorlevel% == 1 (winget install --id=Git.Git -e) else (echo "Git already installed")

echo "Check for installed docker"
winget list | findstr /i docker > nul

if %errorlevel% == 1 (winget install --id=Docker.DockerDesktop -e) else (echo "Docker already installed")

REM git clone nix-config repo
dir | findstr /i nix-configurations > nul
if %errorlevel% == 1 (git clone https://github.com/Chris2011/nix-configurations.git) else (cd nix-configurations && git pull && cd ..)

docker build --platform linux/arm64 --build-arg output_format=sd-aarch64 -f Dockerfile ./nix-configurations