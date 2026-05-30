{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.zellij.system;
in
{
  options.my.applications.zellij.system = {
    enable = lib.mkEnableOption "Zellij system configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      zellij # Terminal multiplexer with batteries included
    ];
  };
}
