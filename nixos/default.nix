{config, pkgs, ...}: let
in {
  imports = [
    ./system
    ./agenix
    ./grafana
    ./jellyfin
  ];
}
