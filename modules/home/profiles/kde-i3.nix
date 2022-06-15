{config, pkgs, lib, ...}: {
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      gaps = {
        outer = 4;
      };
      window = {
        commands = [
          { command = "kill, floating enable, border none"; criteria = {title = "Desktop - Plasma";}; }
          { command = "floating enable"; criteria = {class = "plasmashell";}; }
          { command = "floating enable, border none"; criteria = {class = "Plasma";}; }
          { command = "floating enable, border none"; criteria = {title = "plasma-desktop";}; }
          { command = "floating enable, border none"; criteria = {title = "win7";}; }
          { command = "floating enable, border none"; criteria = {class = "krunner";}; }
          { command = "floating enable, border none"; criteria = {class = "Kmix";}; }
          { command = "floating enable, border none"; criteria = {class = "Klipper";}; }
          { command = "floating enable, border none"; criteria = {class = "Plasmoidviewer";}; }
          { command = "floating enable, border none, move right 700px, move down 450px"; criteria = {class = "plasmashell"; window_type = "notification";}; }
        ];
      };
    };
    extraConfig = ''
      no_focus [class="plasmashell" window_type="notification"] 
    '';
  };
}