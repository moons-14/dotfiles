{ pkgs, ... }:
{
  extraPlugins = [ pkgs.vimPlugins.markview-nvim ];
  extraConfigLua = ''
    require("markview").setup({ initial_state = false })
  '';
}
