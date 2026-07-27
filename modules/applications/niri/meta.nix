{ inputs, ... }:
{
  description = "niri Wayland compositor";

  imports.nixos = [ inputs.niri-flake.nixosModules.niri ];
}
