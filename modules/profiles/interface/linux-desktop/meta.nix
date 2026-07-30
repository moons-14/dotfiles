{
  description = "Shared NixOS graphical desktop foundation";

  includes = [
    "profiles.interface.gui"
    "applications.fcitx5"
    "applications.ghostty"
    "applications.gtk"
    "applications.nautilus"
    "hardwares.graphics"
    "services.fusuma"
    "systems.audio"
    "systems.fonts"
  ];
}
