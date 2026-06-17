{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.fcitx5.homeManager;
in
{
  options.my.applications.fcitx5.homeManager = {
    enable = lib.mkEnableOption "fcitx5 home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf cfg.enable {
        home.file.".config/fcitx5/config" = {
          recursive = true;
          source = ./config;
        };
      };
    }
  ];
}
