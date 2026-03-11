{ pkgs, ... }: {
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.snacks-nvim ];
    extraConfigLua = ''
      require("snacks").setup({
        picker   = { enabled = true },
        notifier = { enabled = true },
        words    = { enabled = true },
        scroll   = { enabled = true },
        dim      = { enabled = true },
      })
    '';
  };
}
