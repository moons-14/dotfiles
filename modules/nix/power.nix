_: {
  boot.kernelParams = [
    "mem_sleep_default=deep"
  ];

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;
  services.upower.enable = true;
}
