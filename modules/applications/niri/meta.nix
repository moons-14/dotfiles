{ inputs, ... }:
{
  description = "niri Wayland compositor";

  includes = [ "systems.wayland" ];

  imports = {
    nixos = [ inputs.niri-flake.nixosModules.niri ];
    home = [ ./niri-home-module.nix ];
  };
}
