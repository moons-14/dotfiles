{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.niri.system;
in
{
  options.my.applications.niri.system = {
    enable = lib.mkEnableOption "niri system configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
  };
}
