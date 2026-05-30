{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.btop.system;
in
{
  options.my.applications.btop.system = {
    enable = lib.mkEnableOption "btop system configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      btop # Resource monitor that shows usage and stats
    ];
  };
}
