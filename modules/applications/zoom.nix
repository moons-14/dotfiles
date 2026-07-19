{
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
    programs.zoom-us.enable = true;
  };
}
