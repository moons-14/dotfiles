{ pkgs, ... }: {
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.glance-nvim ];
    extraConfigLua = ''
      require("glance").setup()
    '';
  };
}
