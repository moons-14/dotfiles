{
  description = "Shared NixOS graphical desktop foundation";

  includes = [
    "profiles.interface.gui"
    "applications.fcitx5"
    "applications.baobab"
    "applications.celluloid"
    "applications.easyeffects"
    "applications.gnome-disk-utility"
    "applications.ghostty"
    "applications.gtk"
    "applications.loupe"
    "applications.nautilus"
    "applications.nani"
    "applications.papers"
    "applications.qalculate-gtk"
    "applications.resources"
    "applications.vlc"
    "applications.dpms-off"
    "hardwares.graphics"
    "services.gvfs"
    "services.evremap"
    "services.polkit-gnome"
    "systems.audio"
    "systems.fonts"
  ];
}
