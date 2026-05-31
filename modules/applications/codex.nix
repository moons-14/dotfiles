{
  pkgs,
  inputs,
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
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex # OpenAI Codex CLI
    ];
  };
}
