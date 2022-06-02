{ config, pkgs, lib, ...}: let
  nixGLNvidiaScript = pkgs.writeShellScriptBin "nixGLNvidia" ''
    $(NIX_PATH=nixpkgs=${pkgs.inputs.nixpkgs} nix-build ${pkgs.inputs.nixgl} -A auto.nixGLNvidia --no-out-link)/bin/* "$@"
  '';
  nixGLIntelScript = pkgs.writeShellScriptBin "nixGLIntel" ''
    $(NIX_PATH=nixpkgs=${pkgs.inputs.nixpkgs} nix-build ${pkgs.inputs.nixgl} -A nixGLIntel --no-out-link)/bin/* "$@"
  '';
  nixGL = pkgs.writeShellScriptBin "nixGL" ''
    glxinfo|egrep "OpenGL vendor|OpenGL renderer"|grep "NVIDIA"
    if [[ $? == 0 ]]
    then
      ${nixGLNvidiaScript}/bin/nixGLNvidia "$@"
    else
      ${nixGLIntelScript}/bin/nixGLIntel "$@"
    fi
  '';
  nixGLWrap = pkg: pkgs.writeShellScriptBin pkg.pname ''
   set -e
   
   ${nixGL}/bin/nixGL ${pkg}/bin/${pkg.pname} "$@"
  '';
in
{

  home.packages = [
    nixGL
  ];

  programs.alacritty.settings.font.size = 7;
  
  programs.home-manager.enable = true;

  home.file.".config/Code/User/settings.json" = {
    source = ../../../conf.d/code/settings.json;
  };

  home.file.".gnupg/gpg-agent.conf" = {
    # TODO use variable for home directory
    text = ''
      enable-ssh-support
    '';
  };

  nix = {
    
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # workaround to enable config generation
    # default value for sandbox is true
    # see https://github.com/nix-community/home-manager/commit/bb860e3e119ee6d043896544de560cd05096a421
    settings = {
      sandbox = true;
    };
    
    enable = true;
    package = pkgs.nixFlakes;
  };

  targets.genericLinux.enable = true;

  xdg = {
    enable = true;
    configFile."nixpkgs/overlays.nix".source = ../../overlays.nix;
  };


  nixpkgs = {
    overlays =
      [
        (final: prev: {
          alacritty = nixGLWrap prev.alacritty;
        })
      ];
  };

}