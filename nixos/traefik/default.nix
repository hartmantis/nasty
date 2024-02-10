{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    traefik
  ];

  services.traefik.staticConfigOptions = {
    entryPoints = {
      http = {
        address = ":80";
      };
    };
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      services = {
        jellyfin = {
          loadBalancer = {
            servers = [
              { url = "http://127.0.0.1:8096"; }
            ];
          };
        };
      };

      routers = {
        jellyfin = {
          rule = "PathPrefix(`/`)";
          service = "jellyfin";
        };
      };
    };
  };

  services.traefik.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 ];
}
