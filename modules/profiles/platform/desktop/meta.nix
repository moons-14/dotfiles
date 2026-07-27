{
  description = "Physical NixOS desktop";

  includes = [
    "profiles.platform.nixos"
    "systems.boot.uefi"
    "systems.hardware"
  ];
}
