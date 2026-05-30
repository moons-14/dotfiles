{
  lib,
  config,
  ...
}:
let
  cfg = config.my.system.hardware.bluetooth;
in
{
  options.my.system.hardware.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support";
  };

  config = lib.mkIf cfg.enable {
    hardware = {
      bluetooth.enable = true;
      bluetooth.powerOnBoot = true;
    };

    services = {
      bluetooth.enable = true;
      bluetooth.startWhenNeeded = true;
      blueman.enable = true;
    };
  };
}
