{config, pkgs, agenix, secrets, ...}: let
  variables = import ../variables/system.nix;
in {
  environment.systemPackages = with pkgs; [
    traefik
  ];

  age.secrets."traefik-env".file = "${secrets}/services/traefik/env.age";

  services.traefik.staticConfigOptions = {
    entryPoints = {
      http = {
        address = ":80";
        http.redirections.entryPoint = {
          to = "https";
        };
      };

      https = {
        address = ":443";
      };
    };

    certificatesResolvers = {
      letsencrypt = {
        acme = {
          email = "letsencrypt@${variables.domain}";
          storage = "${config.services.traefik.dataDir}/acme.json";
          dnsChallenge = {
            provider = "porkbun";
          };
          # caServer = "https://acme-staging-v02.api.letsencrypt.org/directory";
        };
      };
    };
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      services = {
        jellyfin.loadBalancer.servers = [ { url = "http://127.0.0.1:8096"; } ];
      };

      routers = {
        jellyfin-http = {
          rule = "PathPrefix(`/`)";
          entryPoints = [ "http" ];
          service = "jellyfin";
        };

        jellyfin-https = {
          rule = "PathPrefix(`/`)";
          entryPoints = [ "https" ];
          service = "jellyfin";
          tls = {
            domains = [
              {
                main = variables.domain;
                sans = [ "*.${variables.domain}" ];
              }
            ];
            certresolver = "letsencrypt";
          };
        };
      };
    };
  };


  systemd.services.traefik.serviceConfig = {
    EnvironmentFile = [ config.age.secrets.traefik-env.path ];
  };

  services.traefik.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
