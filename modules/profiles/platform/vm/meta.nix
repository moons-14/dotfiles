{
  description = "QEMU NixOS guest";

  includes = [
    "profiles.platform.nixos"
    "hardwares.qemu-guest"
  ];
}
