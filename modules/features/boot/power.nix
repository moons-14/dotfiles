{ lib, config, ... }:
let
  cfg = config.my.features.boot.power;
in
{
  options.my.features.boot.power = {
    enable = lib.mkEnableOption "Power management";
  };

  config = lib.mkIf cfg.enable {
    my.system.power.enable = true;
  };
}
