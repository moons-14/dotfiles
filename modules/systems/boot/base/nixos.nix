{ pkgs, lib, ... }:
{
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 8;
  boot.kernelPackages = pkgs.linuxPackages;
  programs.nix-ld.enable = true;
}
