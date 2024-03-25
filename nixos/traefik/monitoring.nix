{config, pkgs, ...}: let
  ports = import ../variables/ports.nix;
in {
  services.traefik.staticConfigOptions.entryPoints.metrics = {
    address = "localhost:${toString ports.traefik.metrics}";
  };

  services.traefik.staticConfigOptions.metrics = {
    prometheus = {
      entryPoint = "metrics";
    };
  };

  services.traefik.staticConfigOptions.tracing = { };

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
