{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.gui.desktop;
in
{
  options.my.features.gui.desktop = {
    enable = lib.mkEnableOption "Graphical desktop sessions";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        xdg.userDirs = {
          enable = true;
          createDirectories = true;
          desktop = "$HOME/Desktop";
          documents = "$HOME/Documents";
          download = "$HOME/Downloads";
          music = "$HOME/Music";
          pictures = "$HOME/Pictures";
          projects = "$HOME/Projects";
          publicShare = "$HOME/Public";
          templates = "$HOME/Templates";
          videos = "$HOME/Videos";
        };
      }
    ];

    my.applications = {
      gnome.enable = true;
      gtk.enable = true;
      niri.enable = true;
      wayland.enable = true;
      ly.enable = true;
      noctalia.enable = true;
      swayidle.enable = true;
      swaylock.enable = true;
      vicinae.enable = true;
    };
    my.system = {
      fonts.enable = true;
    };
  };
}
