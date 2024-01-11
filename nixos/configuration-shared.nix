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
}