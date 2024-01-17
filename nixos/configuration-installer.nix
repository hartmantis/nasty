{config, pkgs, ...}: let
  rootDevice = builtins.getEnv "NIXOS_ROOT_DEVICE";
  svcName = "nixos-installer";
in {
  imports = [
    ./configuration-shared.nix
  ];

  environment.etc."${svcName}/configuration-shared.nix" = {
    source = ./configuration-shared.nix;
  };

  environment.etc."${svcName}/configuration-system.nix" = {
    source = ./configuration-system.nix;
  };

  # Automate the installation via a run-once systemd service on the installer
  # image. Adapted from
  # https://github.com/tfc/nixos-offline-installer/blob/master/installer-configuration.nix
  systemd.services."${svcName}" = {
    description = "NixOS installer";
    wantedBy = [ "multi-user.target" ];
    after = [ "getty.target" "ncsd.service" ];
    path = [ "/run/current-system/sw" ];
    environment = config.nix.envVars // {
      inherit (config.environment.sessionVariables) NIX_PATH NIXOS_VERSION NIXOS_HOSTNAME NIXOS_DOMAIN NIXOS_ADMIN_USER NIXOS_ADMIN_SSH_PUBLIC_KEY;
      HOME = "/root";
    };
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
      # Use the generated hardware-configuration.nix.
      nixos-generate-config --root /mnt
      cp /etc/${config.environment.etc."${svcName}/configuration-shared.nix".target} /mnt/etc/nixos/base-configuration.nix
      cp /etc/${config.environment.etc."${svcName}/configuration-system.nix".target} /mnt/etc/nixos/configuration.nix

      nixos-install --no-root-passwd
      reboot
    '';
  };
}