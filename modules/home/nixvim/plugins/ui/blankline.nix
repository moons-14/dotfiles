{...}: {
  programs.nixvim.plugins.indent-blankline = {
    enable = true;
    settings = {
      scope = {
        enabled = true;
        show_start = true;
        show_end = true;
      };
      exclude = {
        filetypes = [
          "help"
          "neo-tree"
          "toggleterm"
          "lazy"
        ];
      };
    };
  };
}
