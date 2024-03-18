{config, lib, pkgs, ...}: let
  variables = {
    nixosVersion = builtins.getEnv "NIXOS_VERSION";
    rootDevice = builtins.getEnv "NIXOS_ROOT_DEVICE";
    hostName = builtins.getEnv "NIXOS_HOSTNAME";
    domain = builtins.getEnv "NIXOS_DOMAIN";
    hostId = builtins.getEnv "NIXOS_HOSTID";
    ip = builtins.getEnv "NIXOS_IP_ADDRESS";
    defaultGateway = builtins.getEnv "NIXOS_DEFAULT_GATEWAY";
    dns = builtins.getEnv "NIXOS_DNS";
    bootstrapDeviceName = builtins.getEnv "NIXOS_BOOTSTRAP_DEVICE_NAME";
    adminUser = builtins.getEnv "NIXOS_ADMIN_USER";
    adminSshPublicKey = builtins.getEnv "NIXOS_ADMIN_SSH_PUBLIC_KEY";

    # Template files:
    system = pkgs.substituteAll {
      src = ./variable-templates/system.template;
      nixosVersion = variables.nixosVersion;
      hostName = variables.hostName;
      domain = variables.domain;
      hostId = variables.hostId;
      ip = variables.ip;
      defaultGateway = variables.defaultGateway;
      dns = variables.dns;
      adminUser = variables.adminUser;
      adminSshPublicKey = variables.adminSshPublicKey;
      rootDevice = variables.rootDevice;
    };
  };

  svcName = "nixos-installer";
in {
  assertions = lib.mapAttrsToList (key: value: {
    assertion = value != "";
    message = "${key} is empty!";
  }) variables;

  environment.systemPackages = with pkgs; [
    (stdenv.mkDerivation rec {
      name = "nasty-${version}";
      version = "0.1.0";
      src = ./..;
      dontFixup = true;
      buildInputs = [ git ];
      installPhase = ''
        mkdir -p $out/lib
        cp -r $src $out/lib/nasty

        # The GitHub checkout action checks things out readonly.
        chmod -R +w $out
        # And puts the temporary token in the Git config.
        sed -i -r '/^\s+extraheader/d' $out/lib/nasty/.git/config

        # Drop in templates we've rendered from builder-fed variables.
        mkdir -p $out/lib/nasty/nixos/variables
        cp ${variables.system} $out/lib/nasty/nixos/variables/system.nix

        # Make sure generated files don't accidentally get committed to git.
        pushd $out/lib/nasty
        git update-index --assume-unchanged nixos/variables/system.nix
        popd
      '';
    })
  ];

  # Automate the installation via a run-once systemd service on the installer
  # image. Adapted from
  # https://github.com/tfc/nixos-offline-installer/blob/master/installer-configuration.nix
  systemd.services."${svcName}" = {
    description = "NixOS installer";
    wantedBy = [ "multi-user.target" ];
    after = [ "getty.target" "nss-lookup.target" "ncsd.service" ];
    path = [ "/run/current-system/sw" ];
    environment = config.nix.envVars // {
      inherit (config.environment.sessionVariables) NIX_PATH;
      HOME = "/root";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      StandardOutput = "journal+console";
    };

    script = ''
      set -euxo pipefail

      DNS=false
      while [ "$DNS" != "true" ]; do
        host -t a fastly.com > /dev/null && DNS="true" || sleep 1
      done

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

      nixos-generate-config --root /mnt

      cp -r /nix/store/*-nasty-0.1.0/lib/nasty /mnt/etc/nixos/
      pushd /mnt/etc/nixos
      ln -s nasty/nixos/flake.nix flake.nix
      ln -s nasty/nixos/flake.lock flake.lock
      ln -s nasty/nixos/hardware-configuration.nix hardware-configuration.nix
      popd

      nixos-install --no-root-passwd

      mkdir /bootstrap-device
      mount /dev/disk/by-label/${variables.bootstrapDeviceName} /bootstrap-device
      cp /bootstrap-device/ssh_host_ed25519_key /mnt/etc/ssh/
      cp /bootstrap-device/ssh_host_rsa_key /mnt/etc/ssh/
      cp /bootstrap-device/id_ed25519 /mnt/root/.ssh/
      chown root:root /mnt/etc/ssh/ssh_host_ed25519_key /mnt/etc/ssh/ssh_host_rsa_key /mnt/root/.ssh/id_ed25519
      chmod 0600 /mnt/etc/ssh/ssh_host_ed25519_key /mnt/etc/ssh/ssh_host_rsa_key /mnt/root/.ssh/id_ed25519

      reboot
    '';
  };
}
