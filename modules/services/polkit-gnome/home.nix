{
  config,
  lib,
  pkgs,
  ...
}:
let
  mkSessionService = target: {
    Unit = {
      Description = "GNOME PolicyKit authentication agent";
      Documentation = [ "man:polkit(8)" ];
      PartOf = [ target ];
      After = [ target ];
    };

    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };

    Install.WantedBy = [ target ];
  };
in
{
  systemd.user.services =
    lib.optionalAttrs config.my.applications.niri.enable {
      polkit-gnome-niri = mkSessionService "niri.service";
    }
    // lib.optionalAttrs config.my.applications.labwc.enable {
      polkit-gnome-labwc = mkSessionService "labwc-session.target";
    };
}
