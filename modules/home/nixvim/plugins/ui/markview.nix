{ pkgs, ... }: {
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.markview-nvim ];
    extraConfigLua = ''
      require("markview").setup()
    '';
  };
}
