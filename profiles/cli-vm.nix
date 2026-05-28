{ userName, ... }:
{
  imports = [
    ./cli-minimal.nix
  ];
  home-manager.users.${userName}.imports = [ ];
}
