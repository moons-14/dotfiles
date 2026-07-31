{
  config,
  lib,
  osConfig,
  ...
}:
let
  mkSessionService = target: {
    Unit = {
      Description = "Fcitx 5 input method";
      Documentation = [ "https://fcitx-im.org/" ];
      PartOf = [ target ];
      After = [ target ];
    };

    Service = {
      ExecStart = "${osConfig.i18n.inputMethod.package}/bin/fcitx5 --replace";
      Restart = "on-failure";
    };

    Install.WantedBy = [ target ];
  };
in
{
  home.file.".config/fcitx5/config" = {
    recursive = true;
    source = ./config;
  };

  # niri starts XDG autostart entries through systemd. The explicit service
  # below is shared with labwc, so suppress the package-provided entry.
  xdg.configFile."autostart/org.fcitx.Fcitx5.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

  systemd.user.services =
    lib.optionalAttrs config.my.applications.niri.enable {
      fcitx5-niri = mkSessionService "niri.service";
    }
    // lib.optionalAttrs config.my.applications.labwc.enable {
      fcitx5-labwc = mkSessionService "labwc-session.target";
    };
}
