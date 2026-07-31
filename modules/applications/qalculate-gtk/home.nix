{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [ pkgs.qalculate-gtk ];
}
