{
  description = "UEFI QEMU NixOS guest with NFS client support";

  includes = [
    "profiles.platform.nixos"
    "hardwares.qemu-guest"
    "systems.boot.nfs"
    "systems.boot.uefi"
  ];
}
