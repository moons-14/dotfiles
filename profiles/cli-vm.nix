{ username, ... }:
{
  imports = [
    ./cli-minimal.nix
  ];
  home-manager.users.${username}.imports = [ ];
}
