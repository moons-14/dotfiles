{ pkgs, ... }:
{
  programs.yazi = {
    extraPackages = with pkgs; [
      wl-clipboard
      xdg-utils
    ];
  };
}
