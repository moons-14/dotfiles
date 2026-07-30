_:
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
}
