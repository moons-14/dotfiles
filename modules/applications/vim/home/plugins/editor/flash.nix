{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.flash-nvim ];
    extraConfigLua = ''
      require("flash").setup()
    '';
  };
}
