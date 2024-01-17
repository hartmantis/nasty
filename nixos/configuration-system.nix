{config, pkgs, ...}: let
  adminUser = builtins.getEnv "NIXOS_ADMIN_USER";
  adminSshPublicKey = builtins.getEnv "NIXOS_ADMIN_SSH_PUBLIC_KEY";
in {
  imports = [
    ./hardware-configuration.nix
    ./base-configuration.nix
  ];

  # Copy of what ends up in a default configuration.nix.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # /Copy

  time.timeZone = "Etc/UTC";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.mutableUsers = false;

  users.users.cheese = {
    isNormalUser = true;
    description = "It's me";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [ adminSshPublicKey ];
  };

  security.sudo.extraRules = [
    {
      users = [ adminUser ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  environment.systemPackages = with pkgs; [
    vim
    grafana-agent
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
}