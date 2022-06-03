{config, pkgs, lib, ...}: {
  home.packages = [
    pkgs.helm2
    pkgs.helm3
    pkgs.k9s
    pkgs.kubectl17
  ];
}