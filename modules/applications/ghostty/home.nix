{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.ghostty.homeManager;
in
{
  options.my.applications.ghostty.homeManager = {
    enable = lib.mkEnableOption "ghostty home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf cfg.enable {
        home.file.".config/ghostty/config" = {
          recursive = true;
          source = ./config;
        };

        home.file.".config/ghostty/themes/dracula" = {
          recursive = true;
          source = ./dracula.theme;
        };
      };
    }
  ];
}
