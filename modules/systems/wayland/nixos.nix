{ pkgs, ... }:
{
  programs.xwayland.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    xdgOpenUsePortal = true;
    config = {
      common.default = [ "gtk" ];
      gnome.default = [
        "gnome"
        "gtk"
      ];
      niri.default = [
        "gnome"
        "gtk"
      ];
    };
  };

  environment.variables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = [
    pkgs.xwayland-satellite
    pkgs.uwsm
  ];
}
