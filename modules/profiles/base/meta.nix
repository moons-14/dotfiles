{
  description = "base system configuration";

  includes = [
    "systems.locale"
    "systems.networking"
    "systems.nix"
  ];
}
