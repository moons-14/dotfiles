{...}: {
  programs.nixvim.plugins.lsp-signature = {
    enable = true;
    settings = {
      hint_enable = true;
      hint_prefix = " ";
      floating_window = true;
      bind = true;
    };
  };
}
