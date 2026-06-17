{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.gtk.homeManager;
in
{
  options.my.applications.gtk.homeManager = {
    enable = lib.mkEnableOption "GTK home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf cfg.enable {
        gtk = {
          enable = true;
          theme = {
            name = "Dracula";
            package = pkgs.dracula-theme;
          };
          cursorTheme = {
            package = pkgs.adwaita-icon-theme;
            name = "Adwaita";
          };
          iconTheme = {
            package = pkgs.papirus-icon-theme;
            name = "Papirus-Dark";
          };
        };
      };
    }
  ];
}
