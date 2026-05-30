{
  lib,
  config,
  ...
}:
let
  cfg = config.my.system.power;
in
{
  options.my.system.power = {
    enable = lib.mkEnableOption "power management";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = [
      "mem_sleep_default=deep"
    ];

    powerManagement = {
      enable = true;
      powertop.enable = true;
    };

    services.power-profiles-daemon.enable = true;
    services.tlp.enable = false;
    services.upower.enable = true;
  };
}
