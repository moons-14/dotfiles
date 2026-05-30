{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./gui.nix
    ../modules/system/hardware/bluetooth.nix
    ../modules/system/fingerprint.nix
    ../modules/system/network/wifi.nix
    ../modules/system/power.nix
  ];

  environment.systemPackages = with pkgs; [
    tailscale # Zero-Config VPN
    sbctl # Secure Boot Key Management Tool
  ];

  home-manager.users.${username}.imports = [ ];
}
