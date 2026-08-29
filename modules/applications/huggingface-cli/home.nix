{ pkgs, ... }:
{
  home.packages = [ pkgs.python312Packages.huggingface-hub ];
}
