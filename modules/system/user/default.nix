{
  imports = [
    ./moons.nix
  ];

  nix.settings.allowed-users = [ "moons" ];
  nix.settings.trusted-users = [
    "root"
    "moons"
  ];
}
