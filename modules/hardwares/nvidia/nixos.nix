{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;

    powerManagement = {
      enable = true;
      kernelSuspendNotifier = true;
    };

    moduleParams.nvidia.NVreg_TemporaryFilePath = "/var/tmp";

    nvidiaSettings = true;
  };
}
