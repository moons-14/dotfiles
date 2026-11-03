{ pkgs, ... }:
{
  extraPlugins = [ pkgs.vimPlugins.flash-nvim ];
  extraConfigLua = ''
    require("flash").setup()
  '';
}
