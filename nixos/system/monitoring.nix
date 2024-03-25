{config, pkgs, ...}: let
in {
  services.prometheus.exporters.smartctl = {
    listenAddress = "localhost";
    enable = true;
  };

  services.grafana-agent.settings.metrics.configs = [
    {
      name = "smartctl";
      scrape_configs = [
        {
          job_name = "smartctl";
          static_configs = [
            { targets = [ "localhost:${toString config.services.prometheus.exporters.smartctl.port}" ]; }
          ];
        }
      ];
    }
  ];
}
