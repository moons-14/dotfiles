{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.ghostty.system;
in
{
  options.my.applications.ghostty.system = {
    enable = lib.mkEnableOption "ghostty system configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ghostty # A fast and minimal terminal emulator for Wayland
    ];
  };
}
