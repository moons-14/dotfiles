{ pkgs, ... }:
{
  imports = [
    ./autocmds.nix
    ./colorscheme.nix
    ./keymaps.nix
    ./language.nix
    ./lsp.nix
    ./options.nix
    ./plugins
  ];

  vimAlias = true;
  viAlias = true;
  withNodeJs = true;

  extraPackages = with pkgs; [
    git
    ripgrep
    fd
    nodejs
    zellij
    vtsls
    vscode-langservers-extracted
    tailwindcss-language-server
    prettierd
    prettier
    biome
    stylua
    shfmt
    alejandra
    nixfmt
    lua-language-server
    nixd
    lazygit
  ];
}
