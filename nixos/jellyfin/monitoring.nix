{config, pkgs, ...}: let
  ports = import ../variables/ports.nix;
in {
  services.grafana-agent.settings.metrics.configs = [
    {
      name = "jellyfin";
      scrape_configs = [
        {
          job_name = "jellyfin";
          static_configs = [
            { targets = [ "localhost:${toString ports.jellyfin.web}" ]; }
          ];
        }
      ];
    }
  ];
}
