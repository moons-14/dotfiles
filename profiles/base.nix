{ userName, ... }:
{
  imports = [
    ../modules/nix/boot
    ../modules/nix/caches.nix
    ../modules/nix/gc.nix
    ../modules/nix/hardware
    ../modules/nix/user.nix
    ../modules/nix/network
  ];
  home-manager.users.${userName}.imports = [
  ];
}
