{...}: {
  programs.nixvim.plugins."conform-nvim" = {
    enable = true;
    settings = {
      formatters_by_ft = {
        javascript.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
        javascriptreact.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
        typescript.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
        typescriptreact.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
        json.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
        yaml.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
        markdown.__raw = ''{ "prettierd", "prettier", stop_after_first = true }'';
        lua = ["stylua"];
        nix = ["alejandra"];
        sh = ["shfmt"];
      };
      format_on_save.__raw = ''
        function(_)
          return { timeout_ms = 1000, lsp_format = "fallback" }
        end
      '';
    };
  };
}
