{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.opencode;
in
{
  options.my.applications.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.llm-agents.opencode # OpenCode CLI
    ];
  };
}
