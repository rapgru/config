{ config, pkgs, lib, ... }:

{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    extra-platforms = x86_64-darwin aarch64-darwin 
  '';
  nix.package = pkgs.nixFlakes;

  homebrew = {
    enable = true;
    cleanup = "zap";

    casks = [
      "spotify"
      "visual-studio-code"
      "alacritty"
      "utm"
      "docker"
      "obsidian"
      "homebrew/cask-drivers/synology-drive"
      "vivaldi"
      "tla-plus-toolbox"
    ];

    brews = [
      "tailscale"
      "emacs-plus"
    ];

    taps = [
      "homebrew/core"
      "homebrew/cask"
      "homebrew/cask-drivers"
      "d12frosted/emacs-plus"
    ];

    masApps = {
      YubicoAuthenticator = 1497506650;
      Bitwarden = 1352778147;
    };
  };

  networking.hostName = "macbook";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

  # Any packages that will be used by homebrew casks (regular macOS
  # .dmg applications) do not have access to the user packages.
  environment.systemPackages =
    [ pkgs.git # VS Code
      pkgs.git-crypt # VS Code
      pkgs.coreutils # Emacs
      pkgs.ripgrep # Emacs
    ];

  environment.shells = [
    pkgs.fish
    pkgs.zsh
  ];

  users.users.rgruber.shell = pkgs.fish;
  users.users.rgruber.home = "/Users/rgruber";

  system.defaults = {
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    NSGlobalDomain.KeyRepeat = 5;
    NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
    NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;

    dock.show-recents = false;

    finder.AppleShowAllFiles = true;
    finder.ShowPathbar = true;
  };
  
  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [
    emacs-all-the-icons-fonts
    etBook
    fira-code
    font-awesome
    nerdfonts
    roboto
    roboto-mono
  ];

  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;

  environment.extraInit = ''
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    export PATH="$PATH:/opt/homebrew/bin"
  '';

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
