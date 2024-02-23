{
  description = "A very NASty system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    secrets = {
      url = "git+ssh://git@github.com/hartmantis/nasty-secrets.git";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, agenix, secrets }@inputs: let
    variables = import ./variables/system.nix;
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      "${variables.hostName}" = nixpkgs.lib.nixosSystem {
        modules = [
          agenix.nixosModules.default
          ./hardware-configuration.nix
          ./agenix
          ./system
          ./grafana
          ./jellyfin
          ./traefik
        ];

        specialArgs = { inherit inputs; };
      };
    };
  };
}
