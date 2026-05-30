{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.wayland;
in
{
  options.my.applications.wayland = {
    enable = lib.mkEnableOption "Wayland session support";
  };

  config = lib.mkIf cfg.enable {
    programs.xwayland.enable = true;

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      xdgOpenUsePortal = true;
      config = {
        common.default = [
          "wlr"
          "gtk"
        ];
        niri.default = [
          "wlr"
          "gtk"
        ];
      };
    };

    environment.variables = {
      NIXOS_OZONE_WL = "1";
    };

    environment.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      QT_QPA_PLATFORM = "wayland;xcb";
      NIXOS_OZONE_WL = "1";
    };

    environment.systemPackages = with pkgs; [
      xwayland-satellite # X11 compatibility layer for Wayland
      uwsm # Universal Wayland Session Manager
    ];
  };
}
