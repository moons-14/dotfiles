{
  description = "laptop platform configuration";

  includes = [
    "hardwares.bluetooth"
    "hardwares.ipu6-camera"
    "systems.boot.uefi"
    "systems.fingerprint"
    "systems.networking.wifi"
    "systems.power"
  ];
}
