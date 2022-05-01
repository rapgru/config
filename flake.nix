{
  description = "rapgru's system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixpkgs-unstable;
    darwin.url = "github:lnl7/nix-darwin/master";
    home.url = "github:nix-community/home-manager";
    nixos-generators.url = "github:nix-community/nixos-generators";

    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, nixos-generators, home, ...}@inputs: {
    darwinConfigurations.macbook = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./modules/configuration.nix
        ({ config, pkgs, lib, ... }: {
          nixpkgs.overlays = let
            unstable = import inputs.nixpkgs-unstable {
              system = "aarch64-darwin";
              #inherit (nixpkgsConfig) config;
            };
          in
            [
              (final: prev: {
                
                #sf-mono-liga-bin = pkgs.callPackage ./pkgs/sf-mono-liga-bin { };
                fd = unstable.fd;
              })
            ];
        })
        home.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            
            users.rgruber = import ./modules/home.nix;
          };
        }
      ];
    };

    packages.x86_64-linux = {
      qcow = nixos-generators.nixosGenerate {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          # you can include your own nixos configuration here, i.e.
          # ./configuration.nix
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
        ];
        format = "qcow";
      };
    };
  };
}
