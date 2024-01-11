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

  networking.defaultGateway = "192.168.0.1";
  networking.nameservers = [ "1.1.1.1" ];
}