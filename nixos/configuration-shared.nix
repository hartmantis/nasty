{config, pkgs, ...}:

{
  networking.hostName = builtins.getEnv "NIXOS_HOSTNAME";
  networking.domain = builtins.getEnv "NIXOS_DOMAIN";

  networking.interfaces.eno1.ipv4.addresses = [
    {
      address = "192.168.0.69";
      prefixLength = 24;
    }
  ];

  networking.defaultGateway = "192.168.0.1";
  networking.nameservers = [ "1.1.1.1" ];
}