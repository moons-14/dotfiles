{ lib, config, ... }:
let
  cfg = config.my.features.identity.fingerprint;
in
{
  options.my.features.identity.fingerprint = {
    enable = lib.mkEnableOption "Fingerprint authentication";
  };

  config = lib.mkIf cfg.enable {
    my.system.fingerprint.enable = true;
  };
}
