{ pkgs, ... }:
{
  home.packages = [
    pkgs.nvtopPackages.nvidia
    pkgs.nvitop
  ];
}
