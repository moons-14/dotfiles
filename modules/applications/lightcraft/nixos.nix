{ inputs, ... }:
{
  nixpkgs.overlays = [ (import ../../../overlays/lightcraft.nix { inherit inputs; }) ];
}
