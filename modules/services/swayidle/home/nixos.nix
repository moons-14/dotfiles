{ lib, pkgs, ... }:
let
  brightnessctl = lib.getExe pkgs.brightnessctl;
  loginctl = lib.getExe' pkgs.systemd "loginctl";
  rm = "${pkgs.coreutils}/bin/rm";
  systemctl = lib.getExe' pkgs.systemd "systemctl";
  wlopm = lib.getExe pkgs.wlopm;
  brightnessState = "$XDG_RUNTIME_DIR/swayidle-brightness";

  skipIfOnAC = ''
    for supply in /sys/class/power_supply/*; do
      if [ -f "$supply/type" ] \
        && [ "$(< "$supply/type")" = "Mains" ] \
        && [ -f "$supply/online" ] \
        && [ "$(< "$supply/online")" = "1" ]; then
        exit 0
      fi
    done
  '';

  dimScreen = pkgs.writeShellScript "swayidle-dim-screen" ''
    ${skipIfOnAC}
    ${brightnessctl} get > "${brightnessState}" 2>/dev/null || exit 0
    ${brightnessctl} set 10% >/dev/null 2>&1 || true
  '';

  restoreBrightness = pkgs.writeShellScript "swayidle-restore-brightness" ''
    if [ -f "${brightnessState}" ]; then
      saved=$(< "${brightnessState}")
      ${brightnessctl} set "$saved" >/dev/null 2>&1 || true
      ${rm} -f "${brightnessState}"
    fi
  '';

  suspendOnBattery = pkgs.writeShellScript "swayidle-suspend-on-battery" ''
    ${skipIfOnAC}
    exec ${systemctl} suspend
  '';

  afterResume = pkgs.writeShellScript "swayidle-after-resume" ''
    ${wlopm} --on '*'
    ${restoreBrightness}
  '';

  turnOffLockedDisplays = pkgs.writeShellScript "swayidle-turn-off-locked-displays" ''
    if [ -n "$XDG_SESSION_ID" ] \
      && [ "$(${loginctl} show-session "$XDG_SESSION_ID" --property=LockedHint --value)" = "yes" ]; then
      ${wlopm} --off '*'
    fi
  '';

  turnOnDisplays = pkgs.writeShellScript "swayidle-turn-on-displays" ''
    ${wlopm} --on '*'
  '';
in
{
  services.swayidle = {
    enable = true;
    systemdTargets = [ "graphical-session.target" ];
    timeouts = [
      {
        timeout = 300;
        command = "${dimScreen}";
        resumeCommand = "${restoreBrightness}";
      }
      {
        timeout = 360;
        command = "${suspendOnBattery}";
      }
      {
        # Do not blank an unlocked desktop.  Once the logind session is locked,
        # blank its outputs after ten minutes and restore them on input.
        timeout = 600;
        command = "${turnOffLockedDisplays}";
        resumeCommand = "${turnOnDisplays}";
      }
    ];
    events = {
      after-resume = "${afterResume}";
      lock = "loginctl lock-session";
      before-sleep = "loginctl lock-session";
    };
  };

  systemd.user.services.swayidle.Service.PassEnvironment = [
    "WAYLAND_DISPLAY"
    "XDG_RUNTIME_DIR"
    "DBUS_SESSION_BUS_ADDRESS"
    "XDG_SESSION_ID"
  ];
}
