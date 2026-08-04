{ inputs, ... }:
{
  description = "niri Wayland compositor";

  includes = [
    "systems.wayland"
    "applications.screenshot"
  ];

  imports = {
    nixos = [
      inputs.niri-flake.nixosModules.niri
    ];
  };
}
