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

    # PAM authentication is serial.  Let a supplied password succeed before
    # starting fprintd, whose scan otherwise blocks password verification until
    # its timeout expires.  Submit an empty password to start fingerprint
    # authentication in upstream swaylock.
    security.pam.services.swaylock.rules.auth.fprintd.order =
      config.security.pam.services.swaylock.rules.auth.unix.order + 50;
  };
}
