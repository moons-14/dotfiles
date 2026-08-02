{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  boot.initrd.luks.devices.cryptroot.device =
    "/dev/disk/by-partuuid/04295552-cbb8-4511-ac1e-1171ec20f8d1";

  environment.systemPackages = with inputs.browser-previews.packages.${pkgs.system}; [
    google-chrome-beta
  ];
}
