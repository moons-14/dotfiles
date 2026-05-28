{ userName, ... }:
{
  imports = [
    ./gui.nix
    ../modules/nix/bluetooth.nix
    ../modules/nix/fingerprint.nix
  ];
  home-manager.users.${userName}.imports = [ ];
}
