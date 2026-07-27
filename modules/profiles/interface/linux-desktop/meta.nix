{
  description = "Shared NixOS graphical desktop foundation";

  includes = [
    "applications.fcitx5"
    "applications.ghostty"
    "applications.gtk"
    "applications.nautilus"
    "applications.vicinae"
    "hardwares.graphics"
    "systems.audio"
    "systems.fonts"
  ];
}
