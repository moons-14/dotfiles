{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  boot.initrd.luks.devices.cryptroot.device =
    "/dev/disk/by-partuuid/04295552-cbb8-4511-ac1e-1171ec20f8d1";

  # Keep Windows data and recovery partitions out of UDisks-based file
  # managers. The shared EFI System Partition stays available as /boot.
  services.udev.extraRules = ''
    ENV{ID_PART_ENTRY_UUID}=="0480f887-d1f9-489d-b8fe-78549ced1938", ENV{UDISKS_IGNORE}="1"
    ENV{ID_PART_ENTRY_UUID}=="6c70041b-3f65-4eb1-8b08-18ed20001877", ENV{UDISKS_IGNORE}="1"
  '';

  environment.systemPackages = with inputs.browser-previews.packages.${pkgs.system}; [
    google-chrome-beta
  ];
}
