{
  pkgs,
  userName,
  ...
}:
{
  imports = [
    ./gui.nix
    ../modules/nix/bluetooth.nix
    ../modules/nix/fingerprint.nix
    ../modules/nix/network/wifi.nix
    ../modules/nix/power.nix
  ];

  environment.systemPackages = with pkgs; [
    tailscale # Zero-Config VPN
    sbctl # Secure Boot Key Management Tool
  ];

  home-manager.users.${userName}.imports = [ ];
}
