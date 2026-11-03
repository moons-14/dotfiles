{ pkgs, ... }:
{
  extraPlugins = [ pkgs.vimPlugins.glance-nvim ];
  extraConfigLua = ''
    require("glance").setup()
  '';
}
