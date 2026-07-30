{
  description = "labwc desktop session for NixOS";

  includes = [
    "profiles.interface.linux-desktop"
    "applications.labwc"
    "applications.noctalia"
    "services.ly"
    "services.swayidle"
    "services.swaylock"
  ];
}
