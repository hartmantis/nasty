{config, pkgs, ...}: let
  rootDevice = builtins.getEnv "NIXOS_ROOT_DEVICE";
in {
  imports = [
    ./configuration-shared.nix
  ];

  # Automate the installation via a run-once systemd service on the installer
  # image. Adapted from
  # https://github.com/tfc/nixos-offline-installer/blob/master/installer-configuration.nix
  systemd.services.nixos-installer = {
    description = "NixOS installer";
    wantedBy = [ "multi-user.target" ];
    after = [ "getty.target" "ncsd.service" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };

    script = ''
      set -euxo pipefail

      wipefs -fa /dev/${rootDevice}

      parted /dev/${rootDevice} -- mklabel gpt
      parted /dev/${rootDevice} -- mkpart root ext4 512MB -8GB
      parted /dev/${rootDevice} -- mkpart swap linux-swap -8GB 100%
      parted /dev/${rootDevice} -- mkpart ESP fat32 1MB 512MB
      parted /dev/${rootDevice} -- set 3 esp on

      mkfs.ext4 -L nixos /dev/${rootDevice}p1
      mkswap -L swap /dev/${rootDevice}p2
      swapon /dev/${rootDevice}p2
      mkfs.fat -F 32 -n boot /dev/${rootDevice}p3
      mkdir -p /mnt
      mount /dev/disk/by-label/nixos /mnt
      mkdir -p /mnt/boot
      mount /dev/disk/by-label/boot /mnt/boot
      nixos-generate-config --root /mnt
    '';
  };
}