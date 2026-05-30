{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.gtk;
in
{
  imports = [
    ./system.nix
    ./home.nix
  ];

  options.my.applications.gtk = {
    enable = lib.mkEnableOption "GTK theme configuration";
    system.enable = lib.mkEnableOption "GTK system configuration";
    homeManager.enable = lib.mkEnableOption "GTK home-manager configuration";
  };

  config = lib.mkIf cfg.enable {
    my.applications.gtk.system.enable = lib.mkDefault true;
    my.applications.gtk.homeManager.enable = lib.mkDefault true;
  };
}
