{
  description = "NixOS graphical desktop environment";

  includes = [
    "profiles.interface.cli-interactive"
    "applications.1password"
    "applications.fcitx5"
    "applications.ghostty"
    "applications.gnome"
    "applications.gtk"
    "applications.kde"
    "applications.nautilus"
    "applications.niri"
    "applications.noctalia"
    "applications.vicinae"
    "hardwares.graphics"
    "services.ly"
    "services.swayidle"
    "services.swaylock"
    "systems.audio"
    "systems.fonts"
  ];
}
