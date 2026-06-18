{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.grok;
in
{
  options.my.applications.grok = {
    enable = lib.mkEnableOption "Grok AI assistant";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.llm-agents.grok # Grok AI CLI
    ];
  };
}
