{...}: {
  boot.kernelParams = [
    "mem_sleep_default=deep"
  ];

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
}

