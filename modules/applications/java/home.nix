{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.java.homeManager;
in
{
  options.my.applications.java.homeManager = {
    enable = lib.mkEnableOption "Java home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf cfg.enable {
        programs.java = {
          enable = true;
        };
      };
    }
  ];
}
