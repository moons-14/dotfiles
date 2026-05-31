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
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;
  };
}
