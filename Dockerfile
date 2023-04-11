FROM docker.io/nixos/nix

ARG output_format

RUN nix-channel --add https://nixos.org/channels/nixos-22.11 nixos
RUN nix-channel --update

# Konfigurationsdatei erstellen
COPY nix-configs/machines/octoprint/octoprint.nix /etc/nixos/configuration.nix

ADD nix-configs/common /common

# format: iso, docker, hyperv, install-iso, sd-aar64, sd-aar64-installer, virtualbox, vmware
RUN nix-shell -p nixos-generators --command "nixos-generate -f $output_format -c /etc/nixos/configuration.nix -o result"

# Dell /common folder
RUN rm -rf /common