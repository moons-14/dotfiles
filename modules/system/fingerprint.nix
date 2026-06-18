{
  lib,
  config,
  ...
}:
let
  cfg = config.my.system.fingerprint;
in
{
  options.my.system.fingerprint = {
    enable = lib.mkEnableOption "fingerprint authentication";
  };

  config = lib.mkIf cfg.enable {
    services.fprintd.enable = true;

    security.pam.services = {
      login.fprintAuth = true;
      sudo.fprintAuth = true;
      greetd.fprintAuth = lib.mkForce false;
    };
  };
}
