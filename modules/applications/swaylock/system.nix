{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.swaylock.system;
in
{
  options.my.applications.swaylock.system = {
    enable = lib.mkEnableOption "swaylock system configuration";
  };

  config = lib.mkIf cfg.enable {
    services.systemd-lock-handler.enable = true;

    security.pam.services.swaylock.fprintAuth = true;
  };
}
