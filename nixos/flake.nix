{
  description = "A very NASty system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    variables = import ./variables/system.nix;
  in {
    nixosConfigurations = {
      "${variables.hostName}" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          ./system
          ./agenix
          ./grafana
          ./jellyfin
          ./traefik
        ];
      };
    };
  };
}
