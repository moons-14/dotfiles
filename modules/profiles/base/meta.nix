{
  description = "base system configuration";

  includes = [
    "systems.boot.base"
    "systems.disko"
    "systems.hardware"
    "systems.locale"
    "systems.networking.base"
    "systems.nix"
    "systems.sops"
  ];
}
