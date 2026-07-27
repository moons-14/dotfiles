{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.vim ];
  environment.variables.EDITOR = "nvim";
}
