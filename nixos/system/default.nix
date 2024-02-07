{config, pkgs, ...}: let
  variables = import ../variables/system.nix;
in {
  system.stateVersion = variables.nixosVersion;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Copy of what ends up in a default configuration.nix.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # /Copy
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-partlabel";
  boot.zfs.extraPools = [ "data" ];

  time.timeZone = "Etc/UTC";

  networking.hostName = variables.hostName;
  networking.domain = variables.domain;
  networking.hostId = variables.hostId;

  networking.interfaces.eno1.ipv4.addresses = [
    {
      address = variables.ip;
      prefixLength = 24;
    }
  ];

  networking.defaultGateway = variables.defaultGateway;
  networking.nameservers = [ variables.dns ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.mutableUsers = false;

  users.groups.admins = {
    gid = 1000;
  };

  users.users."${variables.adminUser}" = {
    isNormalUser = true;
    uid = 1000;
    description = "Primary admin user";
    extraGroups = [ "wheel" "admins" ];
    openssh.authorizedKeys.keys = [ variables.adminSshPublicKey ];
  };

  security.sudo.extraRules = [
    {
      users = [ variables.adminUser ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  environment.systemPackages = with pkgs; [
    git
    vim
    zfs
  ];

  programs.tmux.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
