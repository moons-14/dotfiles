{ pkgs, ... }: {
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.snacks-nvim ];
    extraConfigLua = ''
      require("snacks").setup({ picker = { enabled = true } })
    '';
  };
}
