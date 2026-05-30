{
  imports = [
    ./moons.nix
  ];

  users.mutableUsers = true;

  nix.settings.allowed-users = [ "moons" ];
  nix.settings.trusted-users = [
    "root"
    "moons"
  ];
}
