{config, pkgs, ...}: let
in {
  imports = [
    ./hardware-configuration.nix
    ./system/configuration.nix
    ./grafana/configuration.nix
    ./jellyfin/configuration.nix
  ];
}