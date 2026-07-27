{
  description = "base system configuration";

  includes = [
    "systems.locale"
    "systems.networking.base"
    "systems.networking.wifi"
    "systems.nix"
    "systems.sops"
  ];
}
