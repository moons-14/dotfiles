{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  disko.enableConfig = lib.mkDefault false;

  environment.systemPackages = [
    inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
  ];
}
