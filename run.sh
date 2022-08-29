#!/bin/bash
set -u

buildForPc() {
  IMAGE_BASE=''

  COMPOSE_ARGS="-f ./docker/build-nixos-arm/docker-compose.yml"
}

buildForArm() {
  echo "detecting architecture..."

  # Whether to evaluate `docker-compose.emulation.yml`.
  WANTS_EMULATION=

  # case "$(uname -m)" in
  case "$(gh-var-arch)" in
    arm|armel|armhf|arm64|armv[4-9]*l|aarch64)
    # This will use images prefixed with `arm64v8/`, which run natively.
    export IMAGE_BASE=arm64v8/
    echo " detected native ARM architecture, disabling emulation and using image base $IMAGE_BASE"
    ;;
  *)
    echo " detected non-ARM architecture, enabling emulation"
    # [!] Leave WANTS_EMULATION= blank if you don't want to setup emulation with QEMU.
    WANTS_EMULATION=y
    ;;
  esac

  COMPOSE_ARGS="-f ./docker/build-nixos-arm/docker-compose.yml"
  [ -n "$WANTS_EMULATION" ] && COMPOSE_ARGS="$COMPOSE_ARGS -f ./docker/build-nixos-arm/docker-compose.emulation.yml"
}

if ! command -v "docker-compose" >/dev/null 2>&1; then
  echo "error: docker-compose is required to be in \$PATH to run this" >&2
  echo "install instructions: https://docs.docker.com/compose/install/" >&2
  exit 1
fi

# Image base to use. The trick to allow this to work painlessly on both x86 and AArch64 is just
# a magic trick which involves prepending `arm64v8/` when building natively.
export IMAGE_BASE=

# Default 
readonly COMPOSE_ACTION="${1-up}"
[ "$#" -ne 0 ] && shift

echo "(1) Build NixOS for ARM/RaspberryPi";
echo "(2) Build NixOS for PC";

# read -p "Input Selection:" mainmenuinput;

# if [ "$mainmenuinput" = "1" ]; then
  buildForArm
# elif [ "$mainmenuinput" = "2" ]; then
  # buildForPc
# fi

# determine whether to use `sudo` or not
# thanks to masnagam/sbc-scripts for inspiration
# if [ "$(uname)" != Linux ] || [ "$(id -u)" -eq 0 ] || id -nG | grep -q docker; then
if [ "$(gh-var-os)" != Linux ] || [ "$(id -u)" -eq 0 ] || id -nG | grep -q docker; then
  readonly DOCKER_COMPOSE="docker-compose"
else
  if command -v "sudo" >/dev/null 2>&1; then
    readonly DOCKER_COMPOSE="sudo docker-compose"
  else
    echo "warning: you might need to run this script as root"
    readonly DOCKER_COMPOSE="docker-compose"
  fi
fi

if [ -n "$WANTS_EMULATION" ] && [ "$COMPOSE_ACTION" = "up" ]; then
  echo "figuring out if docker-compose >= 2.0.0 workaround is needed..."

  COMPOSE_VERSION="$(docker-compose version --short)"
  COMPOSE_VERSION="${COMPOSE_VERSION%%.*}" # extract major version
  COMPOSE_VERSION="${COMPOSE_VERSION#v}" # remove leading 'v'

  readonly COMPOSE_VERSION

  if [ "$COMPOSE_VERSION" -ge 2 ]; then
    echo "  detected docker-compose $COMPOSE_VERSION, pre-building images"
    $DOCKER_COMPOSE $COMPOSE_ARGS build
  fi
fi

set -x
$DOCKER_COMPOSE $COMPOSE_ARGS $COMPOSE_ACTION "$@"
