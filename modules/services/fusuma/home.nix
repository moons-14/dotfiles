{ lib, pkgs, ... }:
let
  fusuma = lib.getExe pkgs.fusuma;
  nwgDrawer = lib.getExe pkgs.nwg-drawer;
in
{
  home.packages = [ pkgs.fusuma ];

  xdg.configFile."fusuma/config.yml".text = ''
    pinch:
      4:
        in:
          command: "${nwgDrawer} -open"
        out:
          command: "${nwgDrawer} -close"

    threshold:
      pinch: 0.5

    interval:
      pinch: 0.5
  '';

  systemd.user.services.fusuma = {
    Unit = {
      Description = "Fusuma multitouch gesture recognizer";
      Documentation = [ "https://github.com/iberianpig/fusuma" ];
      Requires = [ "nwg-drawer.service" ];
      PartOf = [ "graphical-session.target" ];
      After = [
        "graphical-session.target"
        "nwg-drawer.service"
      ];
    };

    Service = {
      ExecStart = fusuma;
      Restart = "on-failure";
      RestartSec = 3;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
