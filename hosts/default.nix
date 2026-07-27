{
  x1g9 = {
    system = "x86_64-linux";
    stateVersion = "26.05";
    user = "moons";
    path = ./x1g9;

    profiles = [
      "base"
      "interface.cli"
      "interface.gnome"
      "interface.niri"
      "platform.thinkpad-x1"
      "security.fingerprint"
      # "security.secrets"
      "workload.personal"
    ];
  };

  m2 = {
    system = "aarch64-darwin";
    stateVersion = "26.05";
    user = "moons";
    path = ./m2;

    profiles = [
      "base"
      "interface.cli"
      "interface.macos"
      "security.fingerprint"
      # "security.secrets"
      "workload.development"
      "workload.personal"
    ];
  };
}
