{ pkgs, ... }:
{
  extraPlugins = [ pkgs.vimPlugins.nvim-scrollbar ];
  extraConfigLua = ''
    require("scrollbar").setup()
  '';
}
