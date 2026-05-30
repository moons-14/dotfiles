{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.fcitx5;
in
{
  imports = [
    ./system.nix
    ./home.nix
  ];

  options.my.applications.fcitx5 = {
    enable = lib.mkEnableOption "fcitx5 input method";
  };

  config = lib.mkIf cfg.enable {
    my.applications.fcitx5.system.enable = lib.mkDefault true;
    my.applications.fcitx5.homeManager.enable = lib.mkDefault true;
  };
}
