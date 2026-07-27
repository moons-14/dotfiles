{ primaryUser, ... }:
{
  users.users.${primaryUser} = {
    isNormalUser = true;
    description = "moons";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  nix.settings = {
    allowed-users = [ primaryUser ];
    trusted-users = [
      "root"
      primaryUser
    ];
  };
}
