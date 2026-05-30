{ lib, config, ... }:
let
  cfg = config.my.features.gui.camera;
in
{
  options.my.features.gui.camera = {
    enable = lib.mkEnableOption "Camera support";
  };

  config = lib.mkIf cfg.enable {
    my.system.camera.enable = true;
  };
}
