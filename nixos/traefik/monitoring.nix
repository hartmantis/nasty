{config, pkgs, ...}: let
  ports = import ../variables/ports.nix;
in {
  services.grafana-agent.settings.metrics.configs = [
    {
      name = "traefik";
      scrape_configs = [
        {
          job_name = "traefik";
          static_configs = [
            { targets = [ "localhost:${toString ports.traefik.metrics}" ]; }
          ];
        }
      ];
    }
  ];
}
