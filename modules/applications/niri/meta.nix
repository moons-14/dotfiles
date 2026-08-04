{ inputs, ... }:
{
  description = "niri Wayland compositor";

  includes = [
    "systems.wayland"
    "applications.screenshot"
    "applications.wl-find-cursor"
  ];

  imports = {
    nixos = [
      inputs.niri-flake.nixosModules.niri
    ];
  };
}
