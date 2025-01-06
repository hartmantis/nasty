{config, pkgs, variables, ...}: let
  vars = import variables;
  ports = import ../variables/ports.nix;
in {
  environment.systemPackages = with pkgs; [
    navidrome
  ];

  imports = [
    ./config.nix
    ./monitoring.nix
  ];

  services.traefik.dynamicConfigOptions.http.services.navidrome = {
    loadBalancer.servers = [ { url = "http://127.0.0.1:${toString ports.navidrome.http}"; } ];
  };

  services.traefik.dynamicConfigOptions.http.routers.navidrome = {
    entryPoints = [ "https" ];
    rule = "Host(`listen.${vars.domain}`) !PathPrefix(`/metrics`)";
    service = "navidrome";
  };

  services.traefik.dynamicConfigOptions.http.routers.navidrome-metrics = {
    entryPoints = [ "https" ];
    rule = "PathPrefix(`/metrics`)";
    middlewares = [ "forbidden" ];
    service = "navidrome";
  };

  services.navidrome = {
    enable = true;
  };
}
