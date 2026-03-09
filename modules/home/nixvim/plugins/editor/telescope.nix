{...}: {
  programs.nixvim = {
    plugins.telescope = {
      enable = true;
      extensions = {
        fzf-native.enable = true;
      };
      keymaps = {
        "<leader>ff" = {
          action = "find_files";
          options = {
            desc = "ファイルを探す";
            silent = true;
          };
        };

        "<leader>fg" = {
          action = "live_grep";
          options = {
            desc = "文字列を全文検索";
            silent = true;
          };
        };

        "<leader>fb" = {
          action = "buffers";
          options = {
            desc = "開いているバッファを探す";
            silent = true;
          };
        };

        "<leader>fh" = {
          action = "help_tags";
          options = {
            desc = "ヘルプ項目を探す";
            silent = true;
          };
        };
      };
    };
  };
}
