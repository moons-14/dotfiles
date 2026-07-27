{
  description = "virtual-machine platform";

  includes = [
    "hardwares.qemu-guest"
    "systems.boot.nfs"
    "systems.boot.uefi"
  ];
}
