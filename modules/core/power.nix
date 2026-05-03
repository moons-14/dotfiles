{...}: {
  boot.kernelParams = [
    "mem_sleep_default=deep"
  ];

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  services.tlp.enable = false;

  networking.networkmanager.wifi.powersave = false;
}

