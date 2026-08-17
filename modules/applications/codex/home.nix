{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  source = "${config.home.homeDirectory}/dotfiles/modules/applications/codex/config.toml";
in
{
  programs.codex = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;

    # `grill-me` invokes the reusable `grilling` skill.
    skills = {
      grill-me = inputs.skills + "/skills/productivity/grill-me";
      grilling = inputs.skills + "/skills/productivity/grilling";
    };
  };

  home.file = lib.mkIf (!config.home.preferXdgDirectories) {
    ".codex/config.toml".source = config.lib.file.mkOutOfStoreSymlink source;
  };

  xdg.configFile = lib.mkIf config.home.preferXdgDirectories {
    "codex/config.toml".source = config.lib.file.mkOutOfStoreSymlink source;
  };
}
