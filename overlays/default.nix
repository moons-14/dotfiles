{ inputs, ... }:
{
  flake.overlays = {
    default = inputs.llm-agents.overlays.shared-nixpkgs;
  };
}
