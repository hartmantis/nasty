{config, pkgs, ...}: let
  variables = {
    nixosVersion = builtins.getEnv "NIXOS_VERSION";
    rootDevice = builtins.getEnv "NIXOS_ROOT_DEVICE";
    hostName = builtins.getEnv "NIXOS_HOSTNAME";
    domain = builtins.getEnv "NIXOS_DOMAIN";
    ip = builtins.getEnv "NIXOS_IP_ADDRESS";
    defaultGateway = builtins.getEnv "NIXOS_DEFAULT_GATEWAY";
    dns = builtins.getEnv "NIXOS_DNS";
    adminUser = builtins.getEnv "NIXOS_ADMIN_USER";
    adminSshPublicKey = builtins.getEnv "NIXOS_ADMIN_SSH_PUBLIC_KEY";
  };

  svcName = "nixos-installer";
in {
  environment.etc."${svcName}/system/configuration.nix" = {
    source = ./system/configuration.nix;
  };

  environment.etc."${svcName}/system/variables.nix" = {
    source = pkgs.substituteAll {
      src = ./system/variables.template;
      nixosVersion = variables.nixosVersion;
      hostName = variables.hostName;
      domain = variables.domain;
      ip = variables.ip;
      defaultGateway = variables.defaultGateway;
      dns = variables.dns;
      adminUser = variables.adminUser;
      adminSshPublicKey = variables.adminSshPublicKey;
      rootDevice = variables.rootDevice;
    };
  };

  environment.etc."${svcName}/grafana/configuration.nix" = {
    source = ./grafana/configuration.nix;
  };

  environment.etc."${svcName}/jellyfin/configuration.nix" = {
    source = ./jellyfin/configuration.nix;
  };

  environment.etc."${svcName}/configuration.nix" = {
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
      inherit (config.environment.sessionVariables) NIX_PATH;
      HOME = "/root";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };

    script = ''
      set -euxo pipefail

      wipefs -fa /dev/${variables.rootDevice}

      parted /dev/${variables.rootDevice} -- mklabel gpt
      parted /dev/${variables.rootDevice} -- mkpart root ext4 512MB -8GB
      parted /dev/${variables.rootDevice} -- mkpart swap linux-swap -8GB 100%
      parted /dev/${variables.rootDevice} -- mkpart ESP fat32 1MB 512MB
      parted /dev/${variables.rootDevice} -- set 3 esp on

      mkfs.ext4 -L nixos /dev/${variables.rootDevice}p1
      mkswap -L swap /dev/${variables.rootDevice}p2
      swapon /dev/${variables.rootDevice}p2
      mkfs.fat -F 32 -n boot /dev/${variables.rootDevice}p3
      mkdir -p /mnt
      mount /dev/disk/by-label/nixos /mnt
      mkdir -p /mnt/boot
      mount /dev/disk/by-label/boot /mnt/boot
      # Use the generated hardware-configuration.nix.
      nixos-generate-config --root /mnt
      cp -rp /etc/${config.environment.etc."${svcName}"}/* /mnt/etc/nixos/

      nixos-install --no-root-passwd
    '';
  };
}
