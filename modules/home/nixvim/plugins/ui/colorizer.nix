{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = [pkgs.vimPlugins.nvim-colorizer-lua];
    extraConfigLua = ''
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = false,
          css = true,
          tailwind = true,
          mode = "background",
        },
      })
    '';
  };
}
