{ lib, config, ... }:
let
  cfg = config.my.features.gui.audio;
in
{
  options.my.features.gui.audio = {
    enable = lib.mkEnableOption "Audio support (PipeWire)";
  };

  config = lib.mkIf cfg.enable {
    my.system.audio.enable = true;
  };
}
