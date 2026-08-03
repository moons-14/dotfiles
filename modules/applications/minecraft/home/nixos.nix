{ pkgs, ... }:
{
  home.packages = [ pkgs.prismlauncher ];

  programs.prismlauncher.settings = {
    EnableFeralGamemode = true;
  };
}
