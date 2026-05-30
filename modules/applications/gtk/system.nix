{ lib, config, ... }:
let
  cfg = config.my.applications.gtk.system;
in
{
  options.my.applications.gtk.system = {
    enable = lib.mkEnableOption "GTK system configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.dconf.enable = true;
    programs.seahorse.enable = true;
  };
}
