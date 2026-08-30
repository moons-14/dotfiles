{
  description = "Central Nix builder, deploy controller, and binary cache";

  includes = [
    "applications.nix-fleet"
    "services.harmonia"
    "systems.nix.build-server"
    "systems.sops"
  ];
}
