{ userName, ... }:
{
  imports = [
    ./gui.nix
    ../modules/nix/bluetooth.nix
    ../modules/nix/fingerprint.nix
    ../modules/nix/network/wifi.nix
  ];
  home-manager.users.${userName}.imports = [ ];
}
