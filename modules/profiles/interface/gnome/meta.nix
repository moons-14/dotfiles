{
  description = "GNOME desktop session for NixOS";

  includes = [
    "profiles.interface.linux-desktop"
    "applications.gnome"
  ];
}
