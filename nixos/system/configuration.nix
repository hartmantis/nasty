{config, pkgs, ...}: let
  variables = import ../variables/system.nix;
in {
  system.stateVersion = variables.nixosVersion;

  # Copy of what ends up in a default configuration.nix.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # /Copy

  time.timeZone = "Etc/UTC";

  networking.hostName = variables.hostName;
  networking.domain = variables.domain;

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

  users.users."${variables.adminUser}" = {
    isNormalUser = true;
    description = "It's me";
    extraGroups = ["wheel"];
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
    zfs
    vim
  ];
}
