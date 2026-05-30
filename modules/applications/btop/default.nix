{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.btop;
in
{
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.btop = {
    enable = lib.mkEnableOption "btop system monitor";
  };

  config = lib.mkIf cfg.enable {
    my.applications.btop.system.enable = lib.mkDefault true;
    my.applications.btop.homeManager.enable = lib.mkDefault true;
  };
}
