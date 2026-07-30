{ config, lib, ... }:
{
  boot.kernelModules = lib.mkDefault [ "kvm-intel" ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
