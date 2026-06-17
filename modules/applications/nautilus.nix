{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.nautilus;
in
{
  options.my.applications.nautilus = {
    enable = lib.mkEnableOption "Nautilus file manager";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nautilus # GNOME file manager
      gvfs # GNOME virtual file system
      sushi # Nautilus file previewer
    ];
  };
}
