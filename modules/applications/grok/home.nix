{ inputs, pkgs, ... }:
let
  grok = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.grok.overrideAttrs (_: {
    versionCheckProgram = "${placeholder "out"}/libexec/grok/grok-launcher";
  });
in
{
  home.packages = [ grok ];
}
