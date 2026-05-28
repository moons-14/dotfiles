{ userName, ... }:
{
  imports = [
    ../modules/nix/boot
    ../modules/nix/caches.nix
    ../modules/nix/gc.nix
    ../modules/nix/hardware
  ];
  home-manager.users.${userName}.imports = [ ];
}
