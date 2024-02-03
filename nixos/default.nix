{config, pkgs, ...}: let
in {
  imports = [
    ./system
    ./grafana
    ./jellyfin
  ];
}
