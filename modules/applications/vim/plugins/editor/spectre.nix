{ pkgs, ... }:
{
  extraPackages = [ pkgs.ripgrep ];
  extraPlugins = [ pkgs.vimPlugins.nvim-spectre ];
  extraConfigLua = ''
    require("spectre").setup()
  '';
}
