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
    inherit key;
    action.__raw = raw;
    options = {
      silent = true;
      inherit desc;
    };
  };

  mkExpr = key: raw: desc: {
    mode = "n";
    inherit key;
    action.__raw = raw;
    options = {
      silent = true;
      expr = true;
      inherit desc;
    };
  };
in {
  programs.nixvim = {
    opts = {
      # ジャンプ履歴をスタック寄りに扱う
      jumpoptions = "stack";

      # 既に開いているバッファや直前のウィンドウを優先して再利用
      switchbuf = "useopen,uselast";
    };

    keymaps = [
      # Search
      (mk "<Esc>" "<cmd>nohlsearch<CR>" "検索ハイライトを解除")

      # Screen line movement
      (mkExpr "j" "function() return vim.v.count == 0 and 'gj' or 'j' end" "下へ移動（画面行優先）")
      (mkExpr "k" "function() return vim.v.count == 0 and 'gk' or 'k' end" "上へ移動（画面行優先）")

      # LSP: hover / direct jump
      (mkRaw "K" "vim.lsp.buf.hover" "シンボル情報を表示")
      (mkRaw "gd" "vim.lsp.buf.definition" "定義へジャンプ")
      (mkRaw "grr" "vim.lsp.buf.references" "参照一覧を開く")
      (mkRaw "gri" "vim.lsp.buf.implementation" "実装一覧を開く")
      (mkRaw "grt" "vim.lsp.buf.type_definition" "型定義一覧を開く")
      (mkRaw "grn" "vim.lsp.buf.rename" "シンボル名を一括変換")
      (mkRaw "gra" "vim.lsp.buf.code_action" "コードアクション")
      (mkRaw "gO" "vim.lsp.buf.document_symbol" "現在ファイルのシンボル一覧")

      # Glance: preview / peek
      (mk "gD" "<cmd>Glance definitions<CR>" "定義をプレビュー")
      (mk "gR" "<cmd>Glance references<CR>" "参照をプレビュー")
      (mk "gM" "<cmd>Glance implementations<CR>" "実装をプレビュー")
      (mk "gY" "<cmd>Glance type_definitions<CR>" "型定義をプレビュー")
      (mk "g." "<cmd>Glance resume<CR>" "直前のGlanceを再開")

      # Convenience aliases
      (mkRaw "<leader>rn" "vim.lsp.buf.rename" "シンボル名を一括変換")
      (mkRaw "<leader>cf" "function() require('conform').format({ timeout_ms = 1000, lsp_format = 'fallback' }) end" "コードをフォーマット")
      (mkRaw "<leader>ca" "vim.lsp.buf.code_action" "コードアクション")

      # Diagnostics
      (mkRaw "]d" "vim.diagnostic.goto_next" "次の診断へ移動")
      (mkRaw "[d" "vim.diagnostic.goto_prev" "前の診断へ移動")
      (mkRaw "<leader>dl" "vim.diagnostic.open_float" "診断の詳細を表示")

      # File tree
      (mk "<leader>e" "<cmd>Neotree toggle left<CR>" "ファイルツリー")

      # Terminal
      (mk "<leader>tt" "<cmd>ToggleTerm direction=float<CR>" "ターミナル")

      # Trouble
      (mk "<leader>xx" "<cmd>Trouble diagnostics toggle<CR>" "診断一覧")
      (mk "<leader>xq" "<cmd>Trouble qflist toggle<CR>" "Quickfix一覧")
      (mk "<leader>xl" "<cmd>Trouble loclist toggle<CR>" "Location List一覧")
      (mk "<leader>xs" "<cmd>Trouble symbols toggle<CR>" "シンボル一覧")
      (mk "<leader>xw" "<cmd>Trouble lsp toggle<CR>" "LSP一覧")

      # Quickfix / Location list navigation
      (mk "]q" "<cmd>cnext<CR>" "次のQuickfixへ")
      (mk "[q" "<cmd>cprev<CR>" "前のQuickfixへ")
      (mk "]l" "<cmd>lnext<CR>" "次のLocation Listへ")
      (mk "[l" "<cmd>lprev<CR>" "前のLocation Listへ")

      # Window navigation
      (mk "<C-h>" "<C-w>h" "左のウィンドウへ")
      (mk "<C-j>" "<C-w>j" "下のウィンドウへ")
      (mk "<C-k>" "<C-w>k" "上のウィンドウへ")
      (mk "<C-l>" "<C-w>l" "右のウィンドウへ")
      (mk "<C-Left>" "<C-w>h" "左のウィンドウへ")
      (mk "<C-Down>" "<C-w>j" "下のウィンドウへ")
      (mk "<C-Up>" "<C-w>k" "上のウィンドウへ")
      (mk "<C-Right>" "<C-w>l" "右のウィンドウへ")

      # Alternate file / previous file
      (mk "<leader><leader>" "<C-^>" "直前のファイルへ戻る")
      (mk "<leader>w-" "<C-w><C-^>" "直前のファイルをsplitで開く")

      # Buffer Bar
      (mk "[b" "<Cmd>BufferPrevious<CR>" "前のバッファーに移動")
      (mk "]b" "<Cmd>BufferNext<CR>" "次のバッファーに移動")
      (mk "<leader>bc" "<Cmd>BufferClose<CR>" "バッファーを閉じる")

      # Git Conflict
      (mk "<leader>gco" "<cmd>GitConflictChooseOurs<CR>" "現在のブランチを選択")
      (mk "<leader>gct" "<cmd>GitConflictChooseTheirs<CR>" "相手のブランチを選択")
      (mk "<leader>gcb" "<cmd>GitConflictChooseBoth<CR>" "両方を選択")
      (mk "<leader>gcx" "<cmd>GitConflictListQf<CR>" "コンフリクト一覧")
      (mk "]x" "<cmd>GitConflictNextConflict<CR>" "次のコンフリクト")
      (mk "[x" "<cmd>GitConflictPrevConflict<CR>" "前のコンフリクト")

      # Git
      (mk "<leader>gl" "<cmd>LazyGit<CR>" "LazyGitを開く")
      (mk "<leader>gd" "<cmd>DiffviewOpen<CR>" "差分を開く")
      (mk "<leader>gH" "<cmd>DiffviewFileHistory<CR>" "リポジトリ履歴")
      (mk "<leader>gh" "<cmd>DiffviewFileHistory %<CR>" "現在ファイルの履歴")
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

      # Snacks Picker: generic
      (mkRaw "<leader>ff" "function() Snacks.picker.files() end" "ファイルを探す")
      (mkRaw "<leader>fg" "function() Snacks.picker.grep() end" "文字列を全文検索")
      (mkRaw "<leader>fb" "function() Snacks.picker.buffers() end" "開いているバッファを探す")
      (mkRaw "<leader>fh" "function() Snacks.picker.help() end" "ヘルプ項目を探す")
      (mkRaw "<leader>fk" "function() Snacks.picker.keymaps() end" "キーマップを探す")
      (mkRaw "<leader>fc" "function() Snacks.picker.commands() end" "コマンドを探す")

      # Snacks Picker: code navigation
      (mkRaw "<leader>fs" "function() Snacks.picker.lsp_symbols() end" "現在ファイルのシンボルを探す")
      (mkRaw "<leader>fS" "function() Snacks.picker.lsp_workspace_symbols() end" "ワークスペース全体のシンボルを探す")
      (mkRaw "<leader>fr" "function() Snacks.picker.registers() end" "レジスタを探す")
      (mkRaw "<leader>fj" "function() Snacks.picker.jumps() end" "ジャンプ履歴を探す")
      (mkRaw "<leader>fq" "function() Snacks.picker.qflist() end" "Quickfixを探す")
      (mkRaw "<leader>fl" "function() Snacks.picker.loclist() end" "Location Listを探す")
    ];
  };
}
