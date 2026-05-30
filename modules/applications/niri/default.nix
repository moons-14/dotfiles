{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.niri;
in
{
  imports = [
    ./system.nix
    ./home.nix
  ];

  options.my.applications.niri = {
    enable = lib.mkEnableOption "niri window manager";
  };

  config = lib.mkIf cfg.enable {
    my.applications.niri.system.enable = lib.mkDefault true;
    my.applications.niri.homeManager.enable = lib.mkDefault true;
  };
}
