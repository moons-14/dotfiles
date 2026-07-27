{ pkgs, ... }:
{
  home.packages = [
    pkgs.docker-client
    pkgs.oxker
  ];
}
