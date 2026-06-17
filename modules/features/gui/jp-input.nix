{ lib, config, ... }:
let
  cfg = config.my.features.gui.jpInput;
in
{
  options.my.features.gui.jpInput = {
    enable = lib.mkEnableOption "Japanese input method (fcitx5)";
  };

  config = lib.mkIf cfg.enable {
    my.applications.fcitx5.enable = true;
  };
}
