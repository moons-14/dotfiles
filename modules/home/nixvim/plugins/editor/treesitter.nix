{ pkgs, ... }: {
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    extraPlugins = [ pkgs.vimPlugins.nvim-ts-autotag ];
    extraConfigLua = ''
      require("nvim-ts-autotag").setup()
    '';
  };
}
