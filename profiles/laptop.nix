{ ... }:
{
  imports = [
    ./gui.nix
    ./../modules/core/fingerprint.nix
    ./../modules/core/power.nix
    ./../modules/core/camera.nix
  ];

  home-manager.users.moons.imports = [
    
  ];
}