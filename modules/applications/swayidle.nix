{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.my.applications.swayidle;

  noctaliaPkg = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

  noctalia = lib.getExe noctaliaPkg;
  brightnessctl = lib.getExe pkgs.brightnessctl;
  niri = lib.getExe pkgs.niri;
  rm = "${pkgs.coreutils}/bin/rm";

  brightnessState = "$XDG_RUNTIME_DIR/swayidle-brightness";

  noctaliaMsg = command: "${noctalia} msg ${command}";

  lockCmd = noctaliaMsg "session lock";

  # AC 接続中は何もしない。
  # つまり、以下のアイドル処理をバッテリー駆動時のみにする。
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

  lockAndSuspend = pkgs.writeShellScript "swayidle-lock-and-suspend" ''
    ${skipIfOnAC}

    ${noctaliaMsg "session lock-and-suspend"}
  '';

  afterResume = pkgs.writeShellScript "swayidle-after-resume" ''
    ${niri} msg action power-on-monitors
    ${restoreBrightness}
  '';
in
{
  options.my.applications.swayidle = {
    enable = lib.mkEnableOption "swayidle idle manager";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        services.swayidle = {
          enable = true;

          systemdTargets = [
            "graphical-session.target"
          ];

          timeouts = [
            {
              timeout = 300;
              command = "${dimScreen}";
              resumeCommand = "${restoreBrightness}";
            }
            {
              timeout = 360;
              command = "${lockAndSuspend}";
            }
          ];

          events = {
            lock = lockCmd;
            before-sleep = lockCmd;
            after-resume = "${afterResume}";
          };
        };

        systemd.user.services.swayidle.Service.PassEnvironment = [
          "WAYLAND_DISPLAY"
          "XDG_RUNTIME_DIR"
          "DBUS_SESSION_BUS_ADDRESS"
        ];
      }
    ];
  };
}
