{...}: let
  mk = key: action: desc: {
    mode = "n";
    inherit key action;
    options = {
      silent = true;
      inherit desc;
    };
  };

  mkRaw = key: raw: desc: {
    mode = "n";
    key = key;
    action.__raw = raw;
    options = {
      silent = true;
      desc = desc;
    };
  };
in {
  programs.nixvim.keymaps = [
    # Search
    (mk "<Esc>" "<cmd>nohlsearch<CR>" "検索ハイライトを解除")

    # Screen line movement
    {
      mode = "n";
      key = "j";
      action.__raw = "v:count == 0 and 'gj' or 'j'";
      options = { silent = true; expr = true; desc = "下へ移動（画面行優先）"; };
    }
    {
      mode = "n";
      key = "k";
      action.__raw = "v:count == 0 and 'gk' or 'k'";
      options = { silent = true; expr = true; desc = "上へ移動（画面行優先）"; };
    }

    # LSP
    (mkRaw "K" "vim.lsp.buf.hover" "LSPエラーのホバー表示")
    (mk "gd" "<cmd>Glance definitions<CR>" "定義へ移動")
    (mk "gr" "<cmd>Glance references<CR>" "参照を表示")
    (mkRaw "<leader>rn" "vim.lsp.buf.rename" "シンボル名を一括変換")
    (mkRaw "<leader>cf" "function() require('conform').format({ timeout_ms = 1000, lsp_format = 'fallback' }) end" "コードをフォーマット")
    (mkRaw "<leader>ca" "function() vim.lsp.buf.code_action({ context = { diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 }) } }) end" "コードアクション")

    # Diagnostics
    (mkRaw "]d" "vim.diagnostic.goto_next" "次のエラー")
    (mkRaw "[d" "vim.diagnostic.goto_prev" "前のエラー")
    (mkRaw "<leader>dl" "vim.diagnostic.open_float" "エラー詳細")

    # File tree
    (mk "<leader>e" "<cmd>Neotree toggle left<CR>" "ファイルツリー")

    # Terminal
    (mk "<leader>tt" "<cmd>ToggleTerm direction=float<CR>" "ターミナル")

    # Diagnostics list
    (mk "<leader>xx" "<cmd>Trouble diagnostics toggle<CR>" "エラー一覧")

    # Window navigation
    (mk "<C-h>" "<C-w>h" "左のウィンドウへ")
    (mk "<C-j>" "<C-w>j" "下のウィンドウへ")
    (mk "<C-k>" "<C-w>k" "上のウィンドウへ")
    (mk "<C-l>" "<C-w>l" "右のウィンドウへ")

    # Buffer Bar
    (mk "[b" "<Cmd>BufferPrevious<CR>" "前のバッファーに移動")
    (mk "]b" "<Cmd>BufferNext<CR>" "後のバッファーに移動")
    (mk "<leader>bc" "<Cmd>BufferClose<CR>" "バッファーを削除")

    # Git
    (mk "<leader>gl" "<cmd>LazyGit<CR>" "LazyGitを開く")
    (mk "<leader>gd" "<cmd>DiffviewOpen<CR>" "差分を開く")
    (mk "<leader>gH" "<cmd>DiffviewFileHistory<CR>" "リポジトリ履歴")
    (mk "<leader>gh" "<cmd>DiffviewFileHistory %<CR>" "ファイル履歴")
    (mk "<leader>gq" "<cmd>DiffviewClose<CR>" "差分を閉じる")

    # Markview
    (mk "<leader>mp" "<cmd>Markview splitToggle<CR>" "Markdownプレビュー")

    # Zen Mode
    (mk "<leader>zz" "<cmd>ZenMode<CR>" "Zen Modeを開く/閉じる")

    # UFO (folding)
    (mkRaw "zR" "require('ufo').openAllFolds" "全て展開")
    (mkRaw "zM" "require('ufo').closeAllFolds" "全て折りたたむ")

    # Dropbar
    (mkRaw "<leader>dp" "function() require('dropbar.api').pick() end" "dropbarでナビゲート")

    # Snacks
    (mkRaw "<leader>sd" "function() Snacks.dim.toggle() end" "Dimモードをトグル")

    # Flash
    (mkRaw "s" "function() require('flash').jump() end" "Flashジャンプ")
    (mkRaw "S" "function() require('flash').treesitter() end" "Flashツリーシッタ選択")

    # Todo Comments
    (mk "]t" "<cmd>TodoNext<CR>" "次のTODO")
    (mk "[t" "<cmd>TodoPrev<CR>" "前のTODO")
    (mkRaw "<leader>ft" "function() Snacks.picker.todo_comments() end" "TODO一覧")

    # Spectre
    (mkRaw "<leader>sr" "function() require('spectre').toggle() end" "検索・置換")

    # Snacks Picker
    (mkRaw "<leader>ff" "function() Snacks.picker.files() end" "ファイルを探す")
    (mkRaw "<leader>fg" "function() Snacks.picker.grep() end" "文字列を全文検索")
    (mkRaw "<leader>fb" "function() Snacks.picker.buffers() end" "開いているバッファを探す")
    (mkRaw "<leader>fh" "function() Snacks.picker.help() end" "ヘルプ項目を探す")
    (mkRaw "<leader>fk" "function() Snacks.picker.keymaps() end" "キーマップを探す")
    (mkRaw "<leader>fc" "function() Snacks.picker.commands() end" "コマンドを探す")
  ];
}
