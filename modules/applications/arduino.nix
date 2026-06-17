{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.arduino;
in
{
  options.my.applications.arduino = {
    enable = lib.mkEnableOption "Arduino development tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      arduino-cli # Arduino command-line interface
      arduino-ide # Arduino IDE (GUI)
    ];
  };
}
