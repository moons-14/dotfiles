{ pkgs, lib, ... }:
{
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = lib.mkForce false;

  environment.systemPackages = [
    pkgs.gnome-tweaks
    pkgs.gnome-extension-manager
  ];
}
