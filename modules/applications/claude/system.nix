{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.claude.system;
in
{
  options.my.applications.claude.system = {
    enable = lib.mkEnableOption "Claude Code system configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.llm-agents.claude-code # AI coding assistant
    ];
  };
}
