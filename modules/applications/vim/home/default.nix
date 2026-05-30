{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.vim.homeManager;
in
{
  options.my.applications.vim.homeManager = {
    enable = lib.mkEnableOption "vim home-manager configuration";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      inputs.nixvim.homeModules.nixvim
      ./options.nix
      ./autocmds.nix
      ./keymaps.nix
      ./language.nix
      ./colorscheme.nix
      ./lsp.nix
      ./plugins
      {
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
    ];
  };
}
