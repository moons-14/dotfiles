{ pkgs, lib, ... }@args:
lib.mkMerge [
  (import ./autocmds.nix args)
  (import ./colorscheme.nix args)
  (import ./keymaps.nix args)
  (import ./language.nix args)
  (import ./lsp.nix args)
  (import ./options.nix args)
  (import ./plugins args)
  {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    programs.nixvim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      withNodeJs = true;

      nixpkgs = {
        source = pkgs.path;
        config.allowUnfree = true;
      };

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
    };
  }
]
