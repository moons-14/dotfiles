{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fastfetch
    unzip
    wget
  ];
}
