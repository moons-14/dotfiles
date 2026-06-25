{ lib, config, ... }:
let
  cfg = config.my.features.services.quemGuest;
in
{
  options.my.features.services.quemGuest = {
    enable = lib.mkEnableOption "QEMU guest support";
  };

  config = lib.mkIf cfg.enable {
    my.system.quem.enable = true;
  };
}
