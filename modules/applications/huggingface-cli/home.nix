{ pkgs, ... }:
{
  home.packages = [ pkgs.python314Packages.huggingface-hub ];
}
