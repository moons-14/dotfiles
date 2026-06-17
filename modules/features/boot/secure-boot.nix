{ lib, config, ... }:
let
  cfg = config.my.features.boot.secureBoot;
in
{
  options.my.features.boot.secureBoot = {
    enable = lib.mkEnableOption "Secure boot (lanzaboote)";
  };

  config = lib.mkIf cfg.enable {
    my.system.secure-boot.enable = true;
  };
}
