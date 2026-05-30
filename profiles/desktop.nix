{ username, ... }:
{
  imports = [
    ./gui.nix
  ];
  home-manager.users.${username}.imports = [ ];
}
