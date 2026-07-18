{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.grok;

  grok = pkgs.llm-agents.grok.overrideAttrs (_old: {
    versionCheckProgram = "${placeholder "out"}/libexec/grok/grok-launcher";
  });
in
{
  options.my.applications.grok = {
    enable = lib.mkEnableOption "Grok AI assistant";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      grok
    ];
  };
}
