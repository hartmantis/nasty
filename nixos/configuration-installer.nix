{config, pkgs, ...}: let
  variables = {
    githubServerUrl = builtins.getEnv "GITHUB_SERVER_URL";
    githubRepo = builtins.getEnv "GITHUB_REPOSITORY";
    githubRef = builtins.getEnv "GITHUB_REF";
    githubSha = builtins.getEnv "GITHUB_SHA";
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
  assertions = [
    {
      assertion = variables.githubRepo != "";
      message = "githubRepo is empty!";
    }
    {
      assertion = variables.githubRef != "";
      message = "githubRef is empty!";
    }
    {
      assertion = variables.githubSha != "";
      message = "githubSha is empty!";
    }
    {
      assertion = variables.nixosVersion != "";
      message = "nixosVersion is empty!";
    }
    {
      assertion = variables.rootDevice != "";
      message = "rootDevice is empty!";
    }
    {
      assertion = variables.hostName != "";
      message = "hostName is empty!";
    }
    {
      assertion = variables.domain != "";
      message = "domain is empty!";
    }
    {
      assertion = variables.ip != "";
      message = "ip is empty!";
    }
    {
      assertion = variables.defaultGateway != "";
      message = "defaultGateway is empty!";
    }
    {
      assertion = variables.dns != "";
      message = "dns is empty!";
    }
    {
      assertion = variables.adminUser != "";
      message = "adminUser is empty!";
    }
    {
      assertion = variables.adminSshPublicKey != "";
      message = "adminSshPublicKey is empty!";
    }
  ];

  environment.etc.nasty = {
    source = builtins.fetchGit {
      url = "${variables.githubServerUrl}/${variables.githubRepo}";
      ref = variables.githubRef;
      rev = variables.githubSha;
    };
  };

  environment.etc."nixos-variables/system.nix" = {
    source = pkgs.substituteAll {
      src = ../nixos-variable-templates/system.template;
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
    mode = "0644";
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

      cp /etc/nasty/nixos/configuration.nix /mnt/etc/nixos/
      cp -rL /etc/nasty /mnt/etc/
      cp -r /etc/nixos-variables /mnt/etc/

      nixos-install --no-root-passwd
    '';
  };
}
