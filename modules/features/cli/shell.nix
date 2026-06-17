{ lib, config, ... }:
let
  cfg = config.my.features.cli.shell;
in
{
  options.my.features.cli.shell = {
    enable = lib.mkEnableOption "Shell configuration (zsh)";
  };

  config = lib.mkIf cfg.enable {
    my.applications.zsh.enable = true;
  };
}
