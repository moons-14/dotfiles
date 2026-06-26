{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  boot.initrd.luks.devices.cryptroot.device =
    "/dev/disk/by-partuuid/311d0f9c-f35f-42e6-b6fc-a4d67dd21b2e";
}
