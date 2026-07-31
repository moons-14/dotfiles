{
  description = "Physical NixOS desktop";

  includes = [
    "profiles.platform.nixos"
    "services.sunshine"
    "systems.boot.uefi"
    "systems.hardware"
  ];
}
