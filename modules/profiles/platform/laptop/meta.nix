{
  description = "Physical NixOS laptop";

  includes = [
    "profiles.platform.nixos"
    "hardwares.bluetooth"
    "systems.boot.uefi"
    "systems.hardware"
    "systems.networking.wifi"
    "systems.power"
  ];
}
