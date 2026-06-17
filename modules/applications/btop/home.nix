{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.btop.homeManager;
in
{
  options.my.applications.btop.homeManager = {
    enable = lib.mkEnableOption "btop home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf cfg.enable {
        programs.btop = {
          enable = true;
          settings.color_theme = "dracula";
          themes.dracula = builtins.readFile ./dracula.theme;
        };
      };
    }
  ];
}
