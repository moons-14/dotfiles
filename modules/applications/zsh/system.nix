{ lib, config, ... }:
let
  cfg = config.my.applications.zsh.system;
in
{
  options.my.applications.zsh.system = {
    enable = lib.mkEnableOption "Zsh system configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
  };
}
