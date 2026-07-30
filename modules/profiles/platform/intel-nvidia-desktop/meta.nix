{
  description = "Physical NixOS desktop with an Intel CPU and NVIDIA GPU";

  includes = [
    "profiles.platform.desktop"
    "hardwares.intel-cpu"
    "hardwares.nvidia"
  ];
}
