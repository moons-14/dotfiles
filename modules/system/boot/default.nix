{
  pkgs,
  lib,
  ...
}:
{
  boot = {
    loader.systemd-boot.configurationLimit = lib.mkDefault 8;
    kernelPackages = pkgs.linuxPackages_latest;
  };
}
