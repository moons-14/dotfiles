{ inputs, ... }:
{
  flake.overlays.default = _final: prev: {
    llm-agents = inputs.llm-agents.packages.${prev.stdenv.hostPlatform.system};
  };
}
