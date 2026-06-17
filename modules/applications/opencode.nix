{
  pkgs,
  inputs,
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
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode # OpenCode CLI
    ];
  };
}
