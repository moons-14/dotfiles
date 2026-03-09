{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./options.nix
    ./keymaps.nix
    ./language.nix
    ./colorscheme.nix
    ./lsp.nix
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    withNodeJs = true;

    extraPackages = with pkgs; [
      git
      ripgrep
      fd
      nodejs
      zellij

      # LSP / formatter / misc
      vtsls
      vscode-langservers-extracted
      tailwindcss-language-server
      prettierd
      prettier
      biome
      stylua
      shfmt
      alejandra
      lua-language-server
      nixd
    ];

    extraConfigLua = ''
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettierd", "prettier", stop_after_first = true },
          javascriptreact = { "prettierd", "prettier", stop_after_first = true },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "prettierd", "prettier", stop_after_first = true },
          json = { "prettierd", "prettier", stop_after_first = true },
          yaml = { "prettierd", "prettier", stop_after_first = true },
          markdown = { "prettierd", "prettier", stop_after_first = true },
          lua = { "stylua" },
          nix = { "alejandra" },
          sh = { "shfmt" },
        },
        format_on_save = function(_)
          return { timeout_ms = 1000, lsp_format = "fallback" }
        end,
      })

    '';
  };
}
