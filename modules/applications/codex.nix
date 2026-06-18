{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.codex;
in
{
  options.my.applications.codex = {
    enable = lib.mkEnableOption "Codex AI coding assistant";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.llm-agents.codex # OpenAI Codex CLI
    ];
  };
}
