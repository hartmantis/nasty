{config, pkgs, agenix, secrets, variables, ...}: let
  vars = import variables;
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
          email = "letsencrypt@${vars.domain}";
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
        address = "localhost:${toString ports.traefik.metrics}";
      };

      https = {
        address = ":${toString ports.traefik.https}";
        http = {
          tls = {
            domains = [
              {
                main = vars.domain;
                sans = [ "*.${vars.domain}" ];
              }
            ];
            certresolver = "letsencrypt";
          };
        };
      };

      http = {
        address = ":${toString ports.traefik.http}";
        http.redirections.entryPoint = {
          to = "https";
        };
      };
    };
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      middlewares.forbidden = {
        ipWhiteList = {
          sourceRange = [ "127.0.0.1/32" ];
        };
      };
    };
  };

  systemd.services.traefik.serviceConfig = {
    EnvironmentFile = [ config.age.secrets.traefik-env.path ];
  };

  services.traefik.enable = true;

  networking.firewall.allowedTCPPorts = [ ports.traefik.http ports.traefik.https ];

  imports = [
    ./monitoring.nix
  ];
}
