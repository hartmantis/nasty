{
  description = "A very NASty system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    variables = {
      url = "path:/etc/nixos/nasty-variables";
      flake = false;
    };

    secrets = {
      url = "git+ssh://git@github.com/hartmantis/nasty-secrets.git";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, agenix, variables, secrets } @inputs: let
    vars = import variables;
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      "${vars.hostName}" = nixpkgs.lib.nixosSystem {
        modules = [
          agenix.nixosModules.default
          ./hardware-configuration.nix
          ./agenix
          ./system
          ./grafana
          ./jellyfin
          ./navidrome
          ./traefik
        ];

        specialArgs = {
          inherit inputs;
          inherit variables;
          inherit secrets;
        };
      };
    };
  };
}
