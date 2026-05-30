{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.my.applications.swayidle;
  noctaliaPkg = inputs.noctalia.packages.${pkgs.system}.default;
  noctaliaExe = lib.getExe noctaliaPkg;

  lockCmd = "${pkgs.bash}/bin/bash -lc '${noctaliaExe} ipc call lockScreen lock'";
  lockAndSuspendCmd = "${pkgs.bash}/bin/bash -lc '${noctaliaExe} ipc call sessionMenu lockAndSuspend'";
  dpmsOn = "${pkgs.niri}/bin/niri msg action power-on-monitors";
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
          systemdTarget = "graphical-session.target";

          timeouts = [
            {
              timeout = 300;
              command = lockAndSuspendCmd;
            }
          ];

          events = [
            {
              event = "lock";
              command = lockCmd;
            }
            {
              event = "before-sleep";
              command = lockCmd;
            }
            {
              event = "after-resume";
              command = dpmsOn;
            }
          ];
        };

        systemd.user.services.swayidle = {
          Service = {
            PassEnvironment = [
              "WAYLAND_DISPLAY"
              "XDG_RUNTIME_DIR"
              "DBUS_SESSION_BUS_ADDRESS"
            ];
          };
        };
      }
    ];
  };
}
