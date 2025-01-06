{config, pkgs, ...}: let
  ports = import ../variables/ports.nix;
in {
  # services.grafana-agent.settings.metrics.configs = [
  #   {
  #     name = "navidrome";
  #     scrape_configs = [
  #       {
  #         job_name = "navidrome";
  #         static_configs = [
  #           { targets = [ "localhost:${toString ports.navidrome.http}" ]; }
  #         ];
  #       }
  #     ];
  #   }
  # ];
}
