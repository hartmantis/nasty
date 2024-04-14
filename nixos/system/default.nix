{config, pkgs, variables, ...}: let
  vars = import variables;
in {
  system.stateVersion = vars.nixosVersion;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Copy of what ends up in a default configuration.nix.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # /Copy

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-partlabel";
  boot.zfs.extraPools = [ "data" ];
  servies.zfs.autoScrub = {
    enable = false;
    interval = "*-01,04,07,10-01 07:00:00";
  };

  time.timeZone = "Etc/UTC";

  networking.hostName = vars.hostName;
  networking.domain = vars.domain;
  networking.hostId = vars.hostId;

  networking.interfaces.eno1.ipv4.addresses = [
    {
      address = vars.ip;
      prefixLength = 24;
    }
  ];

  networking.defaultGateway = vars.defaultGateway;
  networking.nameservers = [ vars.dns ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.mutableUsers = false;

  users.groups.admins = {
    gid = 1000;
  };

  users.users."${vars.adminUser}" = {
    isNormalUser = true;
    uid = 1000;
    description = "Primary admin user";
    extraGroups = [ "wheel" "admins" ];
    openssh.authorizedKeys.keys = [ vars.adminSshPublicKey ];
  };

  security.sudo.extraRules = [
    {
      users = [ vars.adminUser ];
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
      intel-compute-runtime
    ];
  };

  imports = [
    ./monitoring.nix
  ];
}
