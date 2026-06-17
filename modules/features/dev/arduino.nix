{ lib, config, ... }:
let
  cfg = config.my.features.dev.arduino;
in
{
  options.my.features.dev.arduino = {
    enable = lib.mkEnableOption "Arduino development environment";
  };

  config = lib.mkIf cfg.enable {
    my.applications.arduino.enable = true;
  };
}
