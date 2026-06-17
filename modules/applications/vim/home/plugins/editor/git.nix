{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = [ pkgs.lazygit ];

    plugins = {
      lazygit.enable = true;
      diffview.enable = true;
    };
  };
}
