{ lib, ... }:
{
  hardware = {
    enableRedistributableFirmware = lib.mkDefault true;
    keyboard.qmk.enable = true;
  };
}
