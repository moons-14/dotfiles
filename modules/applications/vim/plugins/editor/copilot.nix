{ pkgs, ... }:
{
  plugins.copilot-lua = {
    enable = true;
    # Pin the release commit: the current Nixpkgs tag archive fails its hash check.
    package = pkgs.vimPlugins.copilot-lua.overrideAttrs {
      src = pkgs.fetchFromGitHub {
        owner = "zbirenbaum";
        repo = "copilot.lua";
        rev = "b1482409cefe8b201f89122c682189fabf0436da";
        hash = "sha256-05f76OeWBlFmlUh90tH4XMMKfNI1jnhuIJDqYPPQokA=";
      };
    };
    settings = {
      suggestion = {
        auto_trigger = true;
        keymap.enabled = false;
      };
    };
  };
}
