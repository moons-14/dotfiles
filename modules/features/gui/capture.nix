{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.gui.capture;
in
{
  options.my.features.gui.capture = {
    enable = lib.mkEnableOption "Screen capture tools (slurp, grim, wf-recorder)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      slurp # Tool for selecting a region of the screen
      grim # Screenshot tool for Wayland
      wf-recorder # Screen recorder for Wayland
    ];
  };
}
