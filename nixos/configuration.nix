{config, pkgs, ...}: let
in {
  imports = [
    ./hardware-configuration.nix
    /etc/nasty/nixos/configuration-system.nix
  ];
}
