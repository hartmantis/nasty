{config, pkgs, ...}: let
  ports = import ../variables/ports.nix;
in {
  boot.kernel.sysctl."user.max_inotify_instances" = 256;
  boot.kernel.sysctl."user.max_inotify_watches" = 503406;

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  imports = [
    ./config.nix
    ./monitoring.nix
  ];

  services.traefik.dynamicConfigOptions.http.services.jellyfin = {
    loadBalancer.servers = [ { url = "http://127.0.0.1:${toString ports.jellyfin.web}"; } ];
  };

  services.traefik.dynamicConfigOptions.http.routers.jellyfin = {
    entryPoints = [ "https" ];
    rule = "PathPrefix(`/`) && !PathPrefix(`/health`) && !PathPrefix(`/metrics`)";
    service = "jellyfin";
  };

  services.traefik.dynamicConfigOptions.http.routers.jellyfin-metrics = {
    entryPoints = [ "https" ];
    rule = "PathPrefix(`/health`) || PathPrefix(`/metrics`)";
    middlewares = [ "forbidden" ];
    service = "jellyfin";
  };

  services.jellyfin = {
    enable = true;
  };
}
