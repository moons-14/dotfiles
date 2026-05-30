{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.snacks-nvim ];

    extraConfigLua = ''
      require("snacks").setup({
        picker = {
          enabled = true,

          actions = require("trouble.sources.snacks").actions,

          win = {
            input = {
              keys = {
                ["<C-t>"] = {
                  "trouble_open",
                  mode = { "n", "i" },
                },
              },
            },
          },
        },

        notifier = { enabled = true },
        words    = { enabled = true },
        scroll   = { enabled = true },
        dim      = { enabled = true },
      })
    '';
  };
}
