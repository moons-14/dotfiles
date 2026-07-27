{
  description = "Foundation shared by all NixOS platforms";

  includes = [
    "systems.disko"
    "systems.boot.base"
    "systems.locale"
    "systems.networking.base"
  ];
}
