{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.ghostty;
in
{
  imports = [
    ./system.nix
    ./home.nix
  ];

  options.my.applications.ghostty = {
    enable = lib.mkEnableOption "ghostty terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    my.applications.ghostty.system.enable = lib.mkDefault true;
    my.applications.ghostty.homeManager.enable = lib.mkDefault true;
  };
}
