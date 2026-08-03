{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.nvim-scrollbar ];
    extraConfigLua = ''
      require("scrollbar").setup()
    '';
  };
}
