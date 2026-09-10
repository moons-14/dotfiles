{
  description = "Foundation shared by all NixOS platforms";

  includes = [
    "services.clatd"
    "services.kmscon"
    "systems.disko"
    "systems.boot.base"
    "systems.locale"
    "systems.networking.base"
  ];
}
