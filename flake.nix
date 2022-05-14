{
  description = "rapgru's system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixpkgs-unstable;
    darwin.url = "github:lnl7/nix-darwin/master";
    home.url = "github:nix-community/home-manager";

    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, home, ...}@inputs: {
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
            
            users.rgruber = import ./modules/home.nix {
              inherit inputs;
              identity = "private";
              isWSL = false;
            };
          };
        }
      ];
    };

    homeConfigurations."rgruber" = home.lib.homeManagerConfiguration
    (let
      system = "x86_64-linux";
      username = "rgruber";
      configName = "rgruber";
    in 
     {
      # Specify the path to your home configuration here
      configuration = import ./modules/home.nix {
        inherit inputs;
        identity = "work";
        isWSL = true;
      };

      inherit system username;
      homeDirectory = "/home/${username}";
      # Update the state version as needed.
      # See the changelog here:
      # https://nix-community.github.io/home-manager/release-notes.html#sec-release-21.05
      stateVersion = "22.05";

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    });
  };
}
