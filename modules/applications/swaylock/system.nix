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

    # Screen unlocking deliberately uses passwords only. Fingerprints remain
    # available to explicitly enabled PAM services such as sudo and polkit.
    security.pam.services.swaylock.fprintAuth = false;
  };
}
