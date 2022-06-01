{
  description = "rapgru's system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixpkgs-unstable;
    darwin.url = "github:lnl7/nix-darwin/master";
    home.url = "github:nix-community/home-manager";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixgl.url = "github:guibou/nixGL";

    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, nixos-generators, home, ...}@inputs: {

    darwinConfigurations.macbook = darwin.lib.darwinSystem (
    let
      system = "aarch64-darwin";
      username = "rgruber";
    in
    {
      inherit system;
      modules = [
        ./modules/configuration.nix
        home.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            
            users."${username}" = import ./modules/home/common.nix {
              inherit inputs system;
              identity = "private";
              type = "darwin";
            };
          };
        }
      ];
    });

    homeConfigurations."rgruber" = home.lib.homeManagerConfiguration
    (let
      system = "x86_64-linux";
      username = "rgruber";
    in 
     {
      # Specify the path to your home configuration here
      configuration = import ./modules/home/common.nix {
        inherit inputs system;
        identity = "work";
        type = "generic-linux";
        profiles = ["work"];
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

    packages.x86_64-linux = {
      qcow = nixos-generators.nixosGenerate {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ({ pkgs, ... }: {
            nix.extraOptions = "experimental-features = nix-command flakes";
            nix.package = pkgs.nix; # If you're still on 21.11

            programs.fish.enable = true;
            users.defaultUserShell = pkgs.fish;

            services.openssh = {
              enable = true;
              passwordAuthentication = false;
              permitRootLogin = "yes";
            };

            users.users."root".openssh.authorizedKeys.keys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqt4kenF3gehfHhTbH1Un9Yc5ClKzHPkuA/7VCkSvq8tI+qrA5JJajuh7MpmGrNVh+aQ88oHOC1fqMJ4XdxJxc3zcvKcaueI78CfqV0MqzSkZADmthlbEonJsh1usgHx+IOxtELPVLw39qTflsHLlAq8gO1mOuQ+pI9TAPnzME6qTafPhkLiTr00S8cW6xcl7dpw0BnGGbEBNiS5ofsbzIYQQfTj1iO/GSBoEMYamJGcsxFdgnqtyZdmctiHjRX/8esOSwL5vbrdklOVJM4ES8U62m5XS3oihnEzBJkKlPWKvvE2cJgdIQGgT5fpl6dQWG8a8jqHU5A7nn2M50sG9mpF0bZupzR6Vg4E8yenEZa2ct06caE4rqlx0CRa3mZexFyqTgS90t3duuyI/NMp8e9lzS5QYWzwBSoYIexA6Q6py5fqE464PeBwsHi6QD8o3+IGPxLME0B8W/lQywHt+YvpHqlm52FqVcjaqrh5Ew3EOYBMrgFbsraChRPdVpWPIVPTVJ6LkwhLkrx33TeO/PnTseNs4AtupKZXDk9jEzC9LYkSHhANTsLo6ZRwXnmjXSjRKAvvQkOZdp2vHg/4IdRVa4OoF2cNHkIVG/sqCKV/HQTppIyqyA8vuwz4Wa2BTLabzjYveI7E+Tw3RF6ocx03FksfwD3Kq+EX8DnCgMWw== cardno:000615587769"
              # note: ssh-copy-id will add user@clientmachine after the public key
              # but we can remove the "@clientmachine" part
            ];
          })
        ];
        format = "qcow";
      };
    };

    nixosConfigurations."installer-iso" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          nix.extraOptions = "experimental-features = nix-command flakes";
          nix.package = pkgs.nix; # If you're still on 21.11

          programs.fish.enable = true;
          users.defaultUserShell = pkgs.fish;

          services.openssh = {
            enable = true;
            passwordAuthentication = false;
            permitRootLogin = "yes";
          };

          users.users."root".openssh.authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqt4kenF3gehfHhTbH1Un9Yc5ClKzHPkuA/7VCkSvq8tI+qrA5JJajuh7MpmGrNVh+aQ88oHOC1fqMJ4XdxJxc3zcvKcaueI78CfqV0MqzSkZADmthlbEonJsh1usgHx+IOxtELPVLw39qTflsHLlAq8gO1mOuQ+pI9TAPnzME6qTafPhkLiTr00S8cW6xcl7dpw0BnGGbEBNiS5ofsbzIYQQfTj1iO/GSBoEMYamJGcsxFdgnqtyZdmctiHjRX/8esOSwL5vbrdklOVJM4ES8U62m5XS3oihnEzBJkKlPWKvvE2cJgdIQGgT5fpl6dQWG8a8jqHU5A7nn2M50sG9mpF0bZupzR6Vg4E8yenEZa2ct06caE4rqlx0CRa3mZexFyqTgS90t3duuyI/NMp8e9lzS5QYWzwBSoYIexA6Q6py5fqE464PeBwsHi6QD8o3+IGPxLME0B8W/lQywHt+YvpHqlm52FqVcjaqrh5Ew3EOYBMrgFbsraChRPdVpWPIVPTVJ6LkwhLkrx33TeO/PnTseNs4AtupKZXDk9jEzC9LYkSHhANTsLo6ZRwXnmjXSjRKAvvQkOZdp2vHg/4IdRVa4OoF2cNHkIVG/sqCKV/HQTppIyqyA8vuwz4Wa2BTLabzjYveI7E+Tw3RF6ocx03FksfwD3Kq+EX8DnCgMWw== cardno:000615587769"
            # note: ssh-copy-id will add user@clientmachine after the public key
            # but we can remove the "@clientmachine" part
          ];
        })
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ];
    };
  };
}
