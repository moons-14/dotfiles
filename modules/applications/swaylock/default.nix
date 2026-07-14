{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.swaylock;
in
{
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.swaylock = {
    enable = lib.mkEnableOption "swaylock screen locker";
  };

  config = lib.mkIf cfg.enable {
    my.applications.swaylock.system.enable = lib.mkDefault true;
    my.applications.swaylock.homeManager.enable = lib.mkDefault true;
  };
}
