{config, pkgs, agenix, secrets, ...}: let
  variables = import ../variables/system.nix;
  ports = import ../variables/ports.nix;
in {
  environment.systemPackages = with pkgs; [
    traefik
  ];

  age.secrets."traefik-env".file = "${secrets}/services/traefik/env.age";

  services.traefik.staticConfigOptions = {
    metrics = {
      prometheus = {
        entryPoint = "metrics";
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

    entryPoints = {
      metrics = {
        address = "localhost:${ports.traefik.metrics}";
      };

      https = {
        address = ":${ports.traefik.https}";
        http = {
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

      http = {
        address = ":${ports.traefik.http}";
        http.redirections.entryPoint = {
          to = "https";
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
        jellyfin-https = {
          rule = "PathPrefix(`/`) && !PathPrefix(`/health`) && !PathPrefix(`/metrics`)";
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

  networking.firewall.allowedTCPPorts = [ ports.traefik.http ports.traefik.https ];
}
