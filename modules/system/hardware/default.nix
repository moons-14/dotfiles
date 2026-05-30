{ lib, ... }:
{
  imports = [
    ./bluetooth.nix
    ./gui.nix
  ];

  hardware = {
    enableRedistributableFirmware = lib.mkDefault true;
    keyboard.qmk.enable = true;
  };

  services.fwupd.enable = true;
}
