{
  pkgs,
  unstable,
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

            # LSP / formatter / misc
            vtsls
            vscode-langservers-extracted
            tailwindcss-language-server
            prettierd
            unstable.prettier
            biome
            stylua
            shfmt
            alejandra
            nixfmt
            lua-language-server
            nixd
          ];
        };
      }
    ];
  };
}
