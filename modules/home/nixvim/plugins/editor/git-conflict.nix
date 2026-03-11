{ pkgs, ... }: {
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.git-conflict-nvim ];
    extraConfigLua = ''
      require("git-conflict").setup()
    '';
  };
}
