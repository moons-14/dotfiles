{
  description = "Foundation shared by all NixOS platforms";

  includes = [
    "systems.boot.base"
    "systems.locale"
    "systems.networking.base"
  ];
}
