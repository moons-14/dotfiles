{
  description = "Foundation shared by all NixOS platforms";

  includes = [
    "services.kmscon"
    "systems.disko"
    "systems.boot.base"
    "systems.locale"
    "systems.networking.base"
  ];
}
