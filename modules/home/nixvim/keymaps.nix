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
    # LSP
    (mkRaw "K" "vim.lsp.buf.hover" "LSPエラーのホバー表示")
    (mkRaw "gd" "vim.lsp.buf.definition" "定義へ移動")
    (mkRaw "gr" "vim.lsp.buf.references" "参照を表示")
    (mkRaw "<leader>rn" "vim.lsp.buf.rename" "シンボル名を一括変換")
    (mkRaw "<leader>cf" "vim.lsp.buf.format" "コードをフォーマット")

    # File tree
    (mk "<leader>e" "<cmd>Neotree toggle left<CR>" "ファイルツリー")

    # Terminal
    (mk "<leader>tt" "<cmd>ToggleTerm direction=float<CR>" "ターミナル")

    # Diagnostics
    (mk "<leader>xx" "<cmd>Trouble diagnostics toggle<CR>" "エラー一覧")

    # Buffer Bar
    (mk "<leader>bh" "<Cmd>BufferPrevious<CR>" "前のバッファーに移動")
    (mk "<leader>bl" "<Cmd>BufferNext<CR>" "後のバッファーに移動")
    (mk "<leader>bc" "<Cmd>BufferClose<CR>" "バッファーを削除")
  ];
}
