{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.zoom;
in
{
  options.my.applications.zoom = {
    enable = lib.mkEnableOption "Zoom video conferencing";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          zoom-us # Video conferencing application
        ];
      }
    ];
  };
}
