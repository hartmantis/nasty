# Borrowed from https://github.com/matt1432/nixos-jellyfin
# Greatly simplified for now while I learn why certain things were done certain ways.
{config, lib, pkgs, ...}: let
  cfg = config.services.jellyfin;
  confDir = "${config.systemd.services.jellyfin.serviceConfig.WorkingDirectory}/config";

  systemConfig = pkgs.writeTextFile {
    name = "jellyfin-system.xml";
    text = builtins.readFile (
      pkgs.substituteAll {
        src = ./templates/system.xml.template;
        enableMetrics = "true";
     }
    );
  };
in {
  systemd.services.jellyfin-conf = {
    before = [ "jellyfin.service" ];
    requiredBy = [ "jellyfin.service" ];
    serviceConfig.WorkingDirectory = confDir;

    script = ''
      set -e

      old_file=$(sha256sum "${confDir}/system.xml" | cut -d ' ' -f 1)
      new_file=$(sha256sum "${systemConfig}" | cut -d ' ' -f 1)

      if [ "$old_file" != "$new_file" ]; then
        rm -f "system.xml.bak"
        mv system.xml system.xml.bak
        cp "${systemConfig}" system.xml
        chown ${cfg.user}:${cfg.group} system.xml
        chmod 0600 system.xml
      fi
    '';
  };

  systemd.services.jellyfin.restartTriggers = [ systemConfig config.systemd.services.jellyfin-conf.script ];
}
