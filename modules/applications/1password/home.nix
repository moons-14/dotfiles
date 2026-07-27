{ pkgs, ... }:
{
  home.packages = [
    pkgs._1password-cli
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs._1password-gui ];
}
