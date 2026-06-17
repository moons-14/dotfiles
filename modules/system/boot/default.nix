{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./nfs.nix
    ./uefi.nix
  ];

  boot = {
    loader.systemd-boot.configurationLimit = lib.mkDefault 8;
    kernelPackages = pkgs.linuxPackages_latest;
  };
  programs.nix-ld.enable = true;
}
