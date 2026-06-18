{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.ly;
in
{
  options.my.applications.ly = {
    enable = lib.mkEnableOption "ly TUI display manager";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.ly = {
      enable = true;
    };
  };
}
