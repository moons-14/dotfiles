{ lib, config, ... }:
let
  cfg = config.my.features.gui.fileManager;
in
{
  options.my.features.gui.fileManager = {
    enable = lib.mkEnableOption "File manager (Nautilus)";
  };

  config = lib.mkIf cfg.enable {
    my.applications.nautilus.enable = true;
  };
}
