{ lib, config, ... }:
let
  cfg = config.my.features.connect.bluetooth;
in
{
  options.my.features.connect.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support";
  };

  config = lib.mkIf cfg.enable {
    my.system.hardware.bluetooth.enable = true;
  };
}
