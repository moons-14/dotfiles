_: {
  programs.nixvim.plugins."conform-nvim" = {
    enable = true;
    settings = {
      formatters_by_ft = {
        javascript.__raw = ''{ "biome", "prettierd", "prettier", stop_after_first = true }'';
        javascriptreact.__raw = ''{ "biome", "prettierd", "prettier", stop_after_first = true }'';
        typescript.__raw = ''{ "biome", "prettierd", "prettier", stop_after_first = true }'';
        typescriptreact.__raw = ''{ "biome", "prettierd", "prettier", stop_after_first = true }'';
        json.__raw = ''{ "biome", "prettierd", "prettier", stop_after_first = true }'';
        yaml.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
        markdown.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
        lua = [ "stylua" ];
        nix.__raw = ''{ "nix_fmt", "alejandra", stop_after_first = true }'';
        sh = [ "shfmt" ];
      };
      formatters.nix_fmt = {
        command = "nix";
        args = [
          "fmt"
          "$FILENAME"
        ];
        stdin = false;
        condition.__raw = ''
          function()
            return vim.fn.executable("nix") == 1 and vim.fn.filereadable(vim.fn.findfile("flake.nix", ".;")) == 1
          end
        '';
      };
      format_on_save.__raw = ''
        function(_)
          return { timeout_ms = 1000, lsp_format = "fallback" }
        end
      '';
    };
  };
}
