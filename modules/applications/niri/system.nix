{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.niri.system;
in
{
  options.my.applications.niri.system = {
    enable = lib.mkEnableOption "niri system configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      wdisplays # Wayland display configuration GUI
      wlr-randr # Wayland output management CLI
    ];
  };
}
