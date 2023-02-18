@echo off

echo "Check for installed git"
winget list | findstr /i git.git > nul

if %errorlevel% == 1 (winget install --id=Git.Git -e) else (echo "Git already installed")

echo "Check for installed podman"
winget list | findstr /i podman > nul

if %errorlevel% == 1 (winget install --id=RedHat.Podman -e) else (echo "Podman already installed")

REM git clone nix-config repo
dir | findstr /i nix-configurations > nul
if %errorlevel% == 1 (git clone https://github.com/Chris2011/nix-configurations.git) else (cd nix-configurations && git pull && cd ..)

podman build --build-arg output_format=sd-aarch64 -f Dockerfile ./nix-configurations