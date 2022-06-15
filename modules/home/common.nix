{ identity, type, profiles ? [], inputs, system }: { config, pkgs, lib, ... }:

let
  identities = lib.importJSON ../../conf.d/secrets/identities.json;
in
{
  home.stateVersion = "22.05";

  # https://github.com/malob/nixpkgs/blob/master/home/default.nix

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  # programs.direnv.enable = true;
  # programs.direnv.nix-direnv.enable = true;

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  # programs.htop.enable = true;
  # programs.htop.settings.show_program_path = true;

  imports = [
    
  ] ++ lib.optionals (type == "darwin") [
    ./types/darwin.nix
  ] ++ lib.optionals (type == "wsl") [
    ./types/wsl.nix
  ] ++ lib.optionals (type == "generic-linux") [
    ./types/generic-linux.nix
  ] ++ lib.optionals (lib.elem "work" profiles) [
    ./profiles/work.nix
  ];

  home.packages = with pkgs; [
    jq

    # deps for fish-fzf
    bat
    fd
    
    ghq

    pass
    bitwarden-cli
    git-crypt

    ripgrep
  ];

  programs.git = {
    enable = true;
    userName = identities.name;
    userEmail = identities.${identity}.email;
    signing.key = identities.${identity}.pgp_keyid;
    signing.signByDefault = true;
    extraConfig.github.user = "rapgru";
    extraConfig.credential.helper = "cache --timeout=28800";
  };

  programs.fzf = {
    enable = true;
  };

  programs.htop = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window.padding.x = 15;
      window.padding.y = 28;
      #window.decorations = "transparent";
      window.dynamic_title = true;
      scrolling.history = 100000;
      live_config_reload = true;
      selection.save_to_clipboard = true;
      mouse.hide_when_typing = true;
      use_thin_strokes = true;

      font = {
        size = lib.mkDefault 12;
        normal.family = "Fira Code";
      };

      colors = {
        cursor.cursor = "#81a1c1";
        primary.background = "#2e3440";
        primary.foreground = "#d8dee9";

        normal = {
          black = "#3b4252";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#88c0d0";
          white = "#e5e9f0";
        };

        bright = {
          black = "#4c566a";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#8fbcbb";
          white = "#eceff4";
        };
      };

      key_bindings = [
        { key = "V"; mods = "Command"; action = "Paste"; }
        { key = "C"; mods = "Command"; action = "Copy"; }
        { key = "Q"; mods = "Command"; action = "Quit"; }
        { key = "Q"; mods = "Control"; chars = "\\x11"; }
        { key = "F"; mods = "Alt"; chars = "\\x1bf"; }
        { key = "B"; mods = "Alt"; chars = "\\x1bb"; }
        { key = "D"; mods = "Alt"; chars = "\\x1bd"; }
        { key = "Key3"; mods = "Alt"; chars = "#"; }
        { key = "Slash"; mods = "Control"; chars = "\\x1f"; }
        { key = "Period"; mods = "Alt"; chars = "\\e-\\e."; }
        {
          key = "N";
          mods = "Command";
          command = {
            program = "open";
            args = [ "-nb" "io.alacritty" ];
          };
        }
      ];
    };
  };
  

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "bobthefish";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-bobthefish";
          rev = "14a6f2b317661e959e13a23870cf89274f867f12";
          sha256 = "kl6XR6IFk5J5Bw7/0/wER4+TnQfC18GKxYbt9C+YHJ0=";
        };
      }
      {
        name = "fzf.fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "8d877a973c1fa22f8bedd8b4cf70243ddcd983ac";
          sha256 = "wFH3be6eGaBpOGkbtyDrh2v3MNG4v51J07T41WiyXdo=";
        };
      }
      {
        name = "fish-docker";
        src = pkgs.fetchFromGitHub {
          owner = "halostatue";
          repo = "fish-docker";
          rev = "541aaa64367755d5a9890b54f9061879ca165027";
          sha256 = "whdM0g+AnVNyGWIuew0nI9LGfkUmp9nTl7GjZRFmD0Y=";
        };
      }
    ];
    shellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      fish_add_path /home/rgruber/.krew/bin
    '';
    functions = {
      ij_open = ''
        fish -c "cd $argv; powershell.exe 'C:\\\"Program Files (x86)\"\JetBrains\\\"IntelliJ IDEA 2021.3.3\"\bin\idea64.exe' ."
      '';
      ij = ''
        set project_path "$HOME/ghq/"(ghq list | fzf)
        ij_open $project_path
      '';
      makelive = ''
        while true
          $argv
          sleep 1
          clear
        end
      '';
      cg = ''
        cd ~/ghq; cd (ghq list | fzf)
      '';
      keeplive = ''
        while true
            sleep 3
            fish -c "$argv"
        end
      '';
      kuc = "kubectl config use-context $argv";
    };
  };


  nixpkgs = {
    config.allowUnfreePredicate = (_: true);
    overlays = let
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
      };
    in
      import ../overlays.nix
      ++
      [
        (final: prev: {
          inherit inputs unstable;
          fd = unstable.fd;
        })
        inputs.nixgl.overlay
      ];
  };

}
