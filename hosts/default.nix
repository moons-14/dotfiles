{
  nix-example = {
    system = "x86_64-linux";
    stateVersion = "26.05";
    user = "moons";
    path = ./nix-example;

    profiles = [
      "base"
      "interface.cli"
      "platform.vm"
      "workload.development"
      "workload.remote-access"
    ];
  };

  ops = {
    system = "x86_64-linux";
    stateVersion = "26.05";
    user = "moons";
    path = ./ops;

    profiles = [
      "base"
      "interface.cli"
      "platform.vm"
      "workload.remote-access"
    ];
  };

  internal-app-01 = {
    system = "x86_64-linux";
    stateVersion = "26.05";
    user = "moons";
    path = ./internal-app-01;

    profiles = [
      "base"
      "interface.cli"
      "platform.vm"
      "workload.server"
    ];
  };

  installer = {
    system = "x86_64-linux";
    stateVersion = "26.05";
    user = "moons";
    path = ./installer;
    homeManager = false;

    profiles = [ "base" ];
  };

  x1g9 = {
    system = "x86_64-linux";
    stateVersion = "26.05";
    user = "moons";
    path = ./x1g9;

    profiles = [
      "base"
      "interface.cli"
      "interface.labwc"
      "interface.niri"
      "platform.thinkpad-x1"
      "security.fingerprint"
      # "security.secrets"
      "workload.personal"
    ];
  };

  x1g13 = {
    system = "x86_64-linux";
    stateVersion = "26.05";
    user = "moons";
    path = ./x1g13;

    profiles = [
      "base"
      "interface.cli"
      "interface.labwc"
      "interface.niri"
      "networking.tailscale-client"
      "platform.thinkpad-x1"
      "security.fingerprint"
      "security.secrets"
      "security.secure-boot"
      "security.tpm-storage"
      "workload.development"
      "workload.game"
      "workload.personal"
    ];
  };

  galleria = {
    system = "x86_64-linux";
    stateVersion = "26.05";
    user = "moons";
    path = ./galleria;

    profiles = [
      "base"
      "interface.cli"
      "interface.labwc"
      "interface.niri"
      "platform.intel-nvidia-desktop"
      "security.secrets"
      "security.secure-boot"
      "security.tpm-storage"
      "security.fingerprint"
      "workload.development"
      "workload.game"
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
      "workload.game"
      "workload.personal"
    ];
  };
}
