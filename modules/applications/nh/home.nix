{ config, pkgs, ... }:
{
  home.packages = [ pkgs.nh ];
  home.sessionVariables.NH_FLAKE = "${config.home.homeDirectory}/dotfiles";
}
