{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  configDirectory =
    if config.home.preferXdgDirectories then
      "${config.xdg.configHome}/codex"
    else
      "${config.home.homeDirectory}/.codex";
  configFile = "${configDirectory}/config.toml";
in
{
  programs.codex = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;

    skills = {
      grilling = inputs.skills + "/skills/productivity/grilling";
    };
  };

  # Keep the repository copy as an initial value. Codex may mutate the live
  # file between activations; each Home Manager switch resets it from here.
  home.activation.resetCodexConfig = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg configDirectory}
      ${pkgs.coreutils}/bin/install -m 0600 ${./config.toml} ${lib.escapeShellArg configFile}
    '';
  };
}
