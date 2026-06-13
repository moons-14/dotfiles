{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  config = {
    disko.enableConfig = true;
  };
}
