{config, pkgs, ...}: let
in {
  imports = [
    ./system/configuration.nix
    ./grafana/configuration.nix
    ./jellyfin/configuration.nix
  ];
}
