{ pkgs, ... }:
{
  programs.java = {
    enable = true;
    package = pkgs.jdk25;
  };

  home.packages = with pkgs; [
    maven
    gradle
  ];
}
