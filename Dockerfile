FROM docker.io/nixos/nix:latest-arm64

ARG output_format

RUN echo "filter-syscalls = false" >> /etc/nix/nix.conf

RUN nix-channel --add https://nixos.org/channels/nixos-22.11 nixos
RUN nix-channel --update

# Konfigurationsdatei erstellen
COPY nix-configs/machines/octoprint/octoprint.nix /etc/nixos/configuration.nix

ADD nix-configs/common /common

# format: iso, docker, hyperv, install-iso, sd-aar64, sd-aar64-installer, virtualbox, vmware
RUN nix-shell -p nixos-generators --command "nixos-generate -f $output_format -c /etc/nixos/configuration.nix -o result"
RUN nix-shell -p zstd --command "unzstd"

# Dell /common folder
RUN rm -rf /common