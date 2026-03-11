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

  };
}
