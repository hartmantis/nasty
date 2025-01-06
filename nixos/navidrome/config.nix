{config, lib, pkgs, ...}: let
in {
  services.navidrome.settings = {
    EnableInsightsCollector = "false";
    MusicFolder = "/data/Music/FLAC";
    Prometheus = {
      Enabled = "true";
      MetricsPath = "/metrics";
    };
  };
}
