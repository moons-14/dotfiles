{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.gui.terminal;
in
{
  options.my.features.gui.terminal = {
    enable = lib.mkEnableOption "Terminal emulators (Ghostty, Alacritty)";
  };

  config = lib.mkIf cfg.enable {
    my.applications.ghostty.enable = true;

    environment.systemPackages = with pkgs; [
      alacritty # A GPU Accelerated Terminal Emulator
    ];
  };
}
