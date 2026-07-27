{
  description = "Intel ThinkPad X1 laptop hardware";

  includes = [
    "profiles.platform.laptop"
    "hardwares.intel-driver"
    "hardwares.ipu6-camera"
    "systems.fingerprint"
  ];
}
