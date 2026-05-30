{ lib, config, ... }:
let
  cfg = config.my.features.boot.uefi;
in
{
  options.my.features.boot.uefi = {
    enable = lib.mkEnableOption "UEFI boot support";
  };

  config = lib.mkIf cfg.enable {
    my.system.boot.uefi.enable = true;
  };
}
