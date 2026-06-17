{
  pkgs,
  inputs,
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
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code # AI coding assistant
    ];
  };
}
