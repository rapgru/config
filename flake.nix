{
  description = "rapgru's system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixpkgs-unstable;
    darwin.url = "github:lnl7/nix-darwin/master";
    home.url = "github:nix-community/home-manager";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixgl.url = "github:guibou/nixGL";
    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs.url = "github:serokell/deploy-rs";

    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, nixos-generators, home, flake-utils, deploy-rs, ...}@inputs: {

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
        profiles = ["work" "kde-i3"];
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

    colmena = let
      ociDomain = "sub06011811570.main.oraclevcn.com";
    in
    {
      meta = {
        nixpkgs = import inputs.nixpkgs-unstable { system = "aarch64-linux"; };
      };

      oci-aarm64-1 = { name, nodes, pkgs, lib, ... }: {
        deployment = {
          targetHost = "130.61.92.191";
          buildOnTarget = true;
        };

        networking.hostName = "nixos-oci-aarm64-1";

        services.k3s.role = "server";
        services.k3s.extraFlags = "--no-deploy traefik --no-deploy=servicelb --flannel-backend=none --disable-network-policy";
        services.k3s.serverAddr = "";

        networking.firewall = {
          allowedUDPPorts = [ 51820 ];
        };

        networking.wireguard.interfaces = {
          # "wg0" is the network interface name. You can name the interface arbitrarily.
          wg0 = {
            # Determines the IP address and subnet of the server's end of the tunnel interface.
            ips = [ "172.16.15.1/30" ];

            # The port that WireGuard listens to. Must be accessible by the client.
            listenPort = 51820;

            # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
            # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
            # postSetup = ''
            #   ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
            # '';

            # This undoes the above command
            # postShutdown = ''
            #  ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
            # '';

            # Path to the private key file.
            #
            # Note: The private key can also be included inline via the privateKey option,
            # but this makes the private key world-readable; thus, using privateKeyFile is
            # recommended.
            privateKey = lib.importJSON ./conf.d/secrets/wg-oci-home/private.json;

            peers = [
              # List of allowed peers.
              { # Feel free to give a meaning full name
                # Public key of the peer (not a file path).
                publicKey = "Q1lm/7WKl6hl4ck2CGeCsOw5FaO7arx741S4RsxwDHE=";
                # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
                allowedIPs = [ "172.16.15.2/32" ];
              }
            ];
          };
        };

        imports = [
          ./modules/system/cluster-node.nix
          ./modules/system/hardware/oci-ubuntu.nix
        ];
      };

      oci-aarm64-2 = { name, nodes, pkgs, ... }: {
        deployment = {
          targetHost = "141.147.47.17";
          buildOnTarget = true;
        };

        networking.hostName = "nixos-oci-aarm64-2";

        services.k3s.role = "agent";

        imports = [
          ./modules/system/cluster-node.nix
          ./modules/system/hardware/oci-ubuntu.nix
        ];
      };

      oci-aarm64-3 = { name, nodes, pkgs, ... }: {
        deployment = {
          targetHost = "141.147.62.61";
          buildOnTarget = true;
        };

        networking.hostName = "nixos-oci-aarm64-3";

        services.k3s.role = "agent";

        imports = [
          ./modules/system/cluster-node.nix
          ./modules/system/hardware/oci-ubuntu.nix
        ];
      };

      oci-aarm64-4 = { name, nodes, pkgs, ... }: {
        deployment = {
          targetHost = "130.61.251.116";
          buildOnTarget = true;
        };

        networking.hostName = "nixos-oci-aarm64-4";

        services.k3s.role = "agent";

        imports = [
          ./modules/system/cluster-node.nix
          ./modules/system/hardware/oci-ubuntu.nix
        ];
      }; 
    };

  } //

  flake-utils.lib.eachDefaultSystem
    (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ oci-cli deploy-rs.packages.${system}.default ];
        };
      }
    );
}
