{ lib, ... }:
{
  hardware = {
    enableRedistributableFirmware = lib.mkDefault true;
    keyboard.qmk.enable = true;
  };

  services.fwupd.enable = true;
}
