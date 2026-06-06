{ lib, ... }:
{
  imports = [
    ./moons.nix
  ];

  users.mutableUsers = lib.mkDefault true;

  nix.settings.allowed-users = [ "moons" ];
  nix.settings.trusted-users = [
    "root"
    "moons"
  ];
}
