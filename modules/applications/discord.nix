{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.discord;
in
{
  options.my.applications.discord = {
    enable = lib.mkEnableOption "Discord (Vesktop)";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.vesktop = {
          enable = true;
        };
      }
    ];
  };
}
