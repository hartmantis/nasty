{config, pkgs, ...}:

{
  networking.hostName = "missjackson";
  networking.domain = "nasty.monster";

  networking.interfaces.eno1.ipv4.addresses = [
    {
      address = "192.168.0.69";
      prefixLength = 24;
    }
  ];

  users.mutableUsers = false;

  users.users.cheese = {
    isNormalUser = true;
    description = "It's me";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWJKtUplJ5KOY7a0Zrl/EswQDLwCpVTt7zI+5zlu9jp nasty"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "cheese" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
}