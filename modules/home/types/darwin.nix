{ config, pkgs, lib, ...} : {

  programs.gpg = {
    enable = true;
    publicKeys =  [ { source = ../../../conf.d/secrets/private-pub.key; trust = 5; } ];
    scdaemonSettings = {
      reader-port = "Yubico YubiKey OTP+FIDO+CCID";
      disable-ccid = true;
    };
  };

  home.file."Library/Application Support/Code/User/settings.json" = {
    source = ../../../conf.d/code/settings.json;
  };

  home.packages = [
    pkgs.m-cli # useful macOS CLI commands
  ];
}