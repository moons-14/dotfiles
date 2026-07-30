{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;

    # RTX 3060 Ti (Ampere) supports NVIDIA's open kernel modules.
    open = true;
  };
}
