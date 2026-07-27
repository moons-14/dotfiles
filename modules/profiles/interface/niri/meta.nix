{
  description = "niri desktop session for NixOS";

  includes = [
    "profiles.interface.linux-desktop"
    "applications.niri"
    "applications.noctalia"
    "services.ly"
    "services.swayidle"
    "services.swaylock"
  ];
}
