{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.swaylock;
  hmCfg = config.my.applications.swaylock.homeManager;
in
{
  options.my.applications.swaylock.homeManager = {
    enable = lib.mkEnableOption "swaylock home-manager configuration";
  };

  config.home-manager.sharedModules = [
    (
      { lib, pkgs, ... }:
      {
        config = lib.mkIf (cfg.enable && hmCfg.enable) {
          home.packages = with pkgs; [
            swaylock # Wayland screen locker using ext-session-lock-v1
          ];

          # systemd-lock-handler holds a sleep inhibitor until this service is
          # ready. swaylock forks only after the compositor confirms the lock.
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
        };
      }
    )
  ];
}
