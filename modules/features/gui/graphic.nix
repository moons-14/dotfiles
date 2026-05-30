{ lib, config, ... }:
let
  cfg = config.my.features.gui.graphic;
in
{
  options.my.features.gui.graphic = {
    enable = lib.mkEnableOption "GPU/graphics hardware acceleration";
  };

  config = lib.mkIf cfg.enable {
    my.system.hardware.gui.enable = true;
  };
}
