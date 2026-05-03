{...}: {
  boot.kernelParams = [
    "mem_sleep_default=deep"
  ];

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  services.power-profiles-daemon.enable = true;
}

