{ inputs, lib, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  config = {
    disko.enableConfig = lib.mkDefault false;
  };
}
