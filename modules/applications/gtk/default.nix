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
    ./home.nix
    ./system.nix
  ];

  options.my.applications.gtk = {
    enable = lib.mkEnableOption "GTK theme configuration";
  };

  config = lib.mkIf cfg.enable {
    my.applications.gtk.system.enable = lib.mkDefault true;
    my.applications.gtk.homeManager.enable = lib.mkDefault true;
  };
}
