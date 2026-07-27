{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [
    pkgs.nautilus
    pkgs.gvfs
    pkgs.sushi
  ];
}
