{config, pkgs, ...}: let
in {
  imports = [
    ./hardware-configuration.nix
    ../../nasty/nixos/configuration-system.nix
  ];
}
