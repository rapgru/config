{ config, pkgs, libs, ...}: {

  home.file."pinentry-wsl-ps1.sh" = {
    source = ../../../conf.d/wsl/pinentry-wsl-ps1.sh;
    executable = true;
  };

  home.file.".gnupg/gpg-agent.conf" = {
    # TODO use variable for home directory
    text = ''
      pinentry-program /home/rgruber/pinentry-wsl-ps1.sh
    '';
  };
}