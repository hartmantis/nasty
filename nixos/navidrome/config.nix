{config, lib, pkgs, agenix, secrets, ...}: let
in {
  age.secrets.navidrome-env.file = "${secrets}/services/navidrome/env.age";

  systemd.services.navidrome.serviceConfig = {
    EnvironmentFile = [ config.age.secrets.navidrome-env.path ];
  };

  services.navidrome.settings = {
    EnableInsightsCollector = false;
    MusicFolder = "/data/Music/FLAC";
    LastFM = {
      Enabled = true;
    };
    ListenBrainz = {
      Enabled = false;
    };
    Prometheus = {
      Enabled = "true";
      MetricsPath = "/metrics";
    };
  };
}
