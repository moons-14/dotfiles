{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.codexDesktop;
in
{
  imports = [
    inputs.codex-desktop-linux.nixosModules.default
  ];

  options.my.applications.codexDesktop = {
    enable = lib.mkEnableOption "ChatGPT Desktop for Linux";
  };

  config = lib.mkIf cfg.enable {
    my.applications.codex.enable = true;

    programs.codexDesktopLinux = {
      enable = true;
      cliPackage = pkgs.llm-agents.codex;
      computerUseUi.enable = true;
    };
  };
}
