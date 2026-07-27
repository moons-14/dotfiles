{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.swaylock ];

  systemd.user.services.swaylock = {
    Unit = {
      Description = "Screen locker for Wayland";
      Documentation = [ "man:swaylock(1)" ];
      OnSuccess = [ "unlock.target" ];
      PartOf = [ "lock.target" ];
      Before = [ "lock.target" ];
    };

    Service = {
      Type = "forking";
      ExecStart = "${lib.getExe pkgs.swaylock} -f -i %h/.wallpapers/28.jpg";
      Restart = "on-failure";
      RestartSec = 0;
    };

    Install.WantedBy = [ "lock.target" ];
  };
}
