{ config, pkgs, lib, ... }: {
  imports = [
  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqt4kenF3gehfHhTbH1Un9Yc5ClKzHPkuA/7VCkSvq8tI+qrA5JJajuh7MpmGrNVh+aQ88oHOC1fqMJ4XdxJxc3zcvKcaueI78CfqV0MqzSkZADmthlbEonJsh1usgHx+IOxtELPVLw39qTflsHLlAq8gO1mOuQ+pI9TAPnzME6qTafPhkLiTr00S8cW6xcl7dpw0BnGGbEBNiS5ofsbzIYQQfTj1iO/GSBoEMYamJGcsxFdgnqtyZdmctiHjRX/8esOSwL5vbrdklOVJM4ES8U62m5XS3oihnEzBJkKlPWKvvE2cJgdIQGgT5fpl6dQWG8a8jqHU5A7nn2M50sG9mpF0bZupzR6Vg4E8yenEZa2ct06caE4rqlx0CRa3mZexFyqTgS90t3duuyI/NMp8e9lzS5QYWzwBSoYIexA6Q6py5fqE464PeBwsHi6QD8o3+IGPxLME0B8W/lQywHt+YvpHqlm52FqVcjaqrh5Ew3EOYBMrgFbsraChRPdVpWPIVPTVJ6LkwhLkrx33TeO/PnTseNs4AtupKZXDk9jEzC9LYkSHhANTsLo6ZRwXnmjXSjRKAvvQkOZdp2vHg/4IdRVa4OoF2cNHkIVG/sqCKV/HQTppIyqyA8vuwz4Wa2BTLabzjYveI7E+Tw3RF6ocx03FksfwD3Kq+EX8DnCgMWw== cardno:000615587769"
  ];

  networking.firewall.allowedTCPPorts = [ 6443 ];

  services.k3s.enable = true;
  services.k3s.docker = false;
  services.k3s.token = lib.importJSON ../../conf.d/secrets/k3s.json;
  services.k3s.serverAddr = lib.mkDefault "https://172.16.11.145:6443";

  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  nixpkgs.config.allowUnfree = true;
}