{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.zed.homeManager;
in
{
  options.my.applications.zed.homeManager = {
    enable = lib.mkEnableOption "Zed home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf cfg.enable {
        programs.zed-editor.enable = true;
      };
    }
  ];
}
