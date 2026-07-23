{ inputs, ... }:
{
  flake.overlays.default = final: {
    llm-agents = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system};
  };
}
