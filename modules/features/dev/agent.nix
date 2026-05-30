{ lib, config, ... }:
let
  cfg = config.my.features.dev.agent;
in
{
  options.my.features.dev.agent = {
    enable = lib.mkEnableOption "AI coding agents (Claude Code)";
  };

  config = lib.mkIf cfg.enable {
    my.applications.claude.enable = true;
  };
}
