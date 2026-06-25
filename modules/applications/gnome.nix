{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.gnome;
in
{
  options.my.applications.gnome = {
    enable = lib.mkEnableOption "GNOME desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.gnome.enable = true;

    # ly is the display manager for switching between installed sessions.
    services.displayManager.gdm.enable = lib.mkForce false;

    environment.systemPackages = with pkgs; [
      gnome-tweaks # GNOME desktop customization tool
      gnome-extension-manager # GNOME Shell extension manager
    ];
  };
}
