{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nautilus
    gvfs sushi
  ];


}
