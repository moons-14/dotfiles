{ pkgs, ... }:
{
  programs.nixvim = {
    opts = {
      foldcolumn = "1";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
    };

    extraPlugins = [
      pkgs.vimPlugins.nvim-ufo
      pkgs.vimPlugins.promise-async
    ];

    extraConfigLua = ''
      require("ufo").setup({
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
      })
    '';
  };
}
