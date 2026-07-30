{ lib, pkgs, ... }:
let
  brightnessctl = lib.getExe pkgs.brightnessctl;
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
in
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
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
    ];
    events.after-resume = "${afterResume}";
  };

  systemd.user.services.swayidle.Service.PassEnvironment = [
    "WAYLAND_DISPLAY"
    "XDG_RUNTIME_DIR"
    "DBUS_SESSION_BUS_ADDRESS"
  ];
}
