{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.todo-comments-nvim ];
    extraConfigLua = ''
      require("todo-comments").setup()
    '';
  };
}
