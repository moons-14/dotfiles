{ lib, pkgs, ... }:
let
  brightnessctl = lib.getExe pkgs.brightnessctl;
  loginctl = lib.getExe' pkgs.systemd "loginctl";
  rm = lib.getExe' pkgs.coreutils "rm";
  systemctl = lib.getExe' pkgs.systemd "systemctl";
  wlopm = lib.getExe pkgs.wlopm;
  noctalia = lib.getExe pkgs.noctalia-shell;

  brightnessState = "$XDG_RUNTIME_DIR/swayidle-brightness";

  onBattery = pkgs.writeShellScript "swayidle-on-battery" ''
    for supply in /sys/class/power_supply/*; do
      [ -f "$supply/type" ] || continue
      [ "$(< "$supply/type")" = "Battery" ] || continue
      [ -f "$supply/status" ] || continue
      [ "$(< "$supply/status")" = "Discharging" ] && exit 0
    done

    exit 1
  '';

  isLocked = pkgs.writeShellScript "swayidle-is-locked" ''
    [ -n "$XDG_SESSION_ID" ] \
      && [ "$(${loginctl} show-session "$XDG_SESSION_ID" \
        --property=LockedHint --value)" = "yes" ]
  '';

  dimScreen = pkgs.writeShellScript "swayidle-dim-screen" ''
    if ${onBattery}; then
      ${brightnessctl} get > "${brightnessState}" 2>/dev/null || exit 0
      ${brightnessctl} set 10% >/dev/null 2>&1 || true
    elif ${isLocked}; then
      ${wlopm} --off '*'
    fi
  '';

  restoreScreen = pkgs.writeShellScript "swayidle-restore-screen" ''
    ${wlopm} --on '*' >/dev/null 2>&1 || true

    if [ -f "${brightnessState}" ]; then
      ${brightnessctl} set "$(< "${brightnessState}")" >/dev/null 2>&1 || true
      ${rm} -f "${brightnessState}"
    fi
  '';

  suspend = pkgs.writeShellScript "swayidle-suspend" ''
    if ${onBattery} || ${isLocked}; then
      exec ${systemctl} suspend
    fi
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
        resumeCommand = "${restoreScreen}";
      }
      {
        timeout = 360;
        command = "${suspend}";
      }
    ];

    events = {
      lock = "${noctalia} msg session lock";
      before-sleep = "${noctalia} msg session lock";
      after-resume = "${restoreScreen}";
    };
  };
}
