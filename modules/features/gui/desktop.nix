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
    my.applications = {
      gnome.enable = true;
      gtk.enable = true;
      niri.enable = true;
      wayland.enable = true;
      ly.enable = true;
      noctalia.enable = true;
      swayidle.enable = true;
      vicinae.enable = true;
    };
    my.system = {
      fonts.enable = true;
    };
  };
}
