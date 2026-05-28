{ userName, ... }:
{
  imports = [
    ../modules/nix/boot.nix
    ../modules/nix/caches.nix
  ];
  home-manager.users.${userName}.imports = [ ];
}
