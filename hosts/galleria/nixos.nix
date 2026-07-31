{ inputs, pkgs, ... }:
let
  diskIdentifiers = import ./disk-identifiers.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  boot.initrd.luks.devices.cryptroot.device =
    "/dev/disk/by-partuuid/${diskIdentifiers.nixosPartUuid}";

  environment.systemPackages = with inputs.browser-previews.packages.${pkgs.system}; [
    google-chrome-beta
  ];
}
