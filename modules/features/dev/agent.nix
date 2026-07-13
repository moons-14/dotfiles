{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.dev.agent;
in
{
  options.my.features.dev.agent = {
    enable = lib.mkEnableOption "AI coding agents (Claude Code, Codex, OpenCode)";
  };

  config = lib.mkIf cfg.enable {
    my.applications = {
      claude.enable = true;
      codex.enable = true;
      opencode.enable = true;
      grok.enable = true;
      codexDesktop.enable = true;
    };
  };
}
