{ lib, pkgs, ... }:
let
  nwgDrawer = lib.getExe pkgs.nwg-drawer;
in
{
  home.packages = [ pkgs.nwg-drawer ];

  # Keep the application grid resident so touchpad gestures can show it
  # immediately instead of rebuilding the desktop-entry cache each time.
  systemd.user.services.nwg-drawer = {
    Unit = {
      Description = "Resident nwg-drawer application grid";
      Documentation = [ "https://github.com/nwg-piotr/nwg-drawer" ];
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      # Use niri's spawn action when available; nwg-drawer falls back to a
      # direct launch under labwc.
      ExecStart = "${nwgDrawer} -r -ovl -wm niri -closebtn right -fm nautilus -term ghostty";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
