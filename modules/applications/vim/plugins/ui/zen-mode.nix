{ pkgs, ... }:
{
  extraPlugins = [ pkgs.vimPlugins.zen-mode-nvim ];
  extraConfigLua = ''
    require("zen-mode").setup()
  '';
}
