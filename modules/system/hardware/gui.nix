{
  lib,
  config,
  ...
}:
let
  cfg = config.my.system.hardware.gui;
in
{
  options.my.system.hardware.gui = {
    enable = lib.mkEnableOption "GPU/graphics hardware acceleration";
  };

  config = lib.mkIf cfg.enable {
    hardware = {
      graphics.enable = true;
    };
  };
}
