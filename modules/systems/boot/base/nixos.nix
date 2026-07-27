{ pkgs, lib, ... }:
{
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 8;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  programs.nix-ld.enable = true;
}
