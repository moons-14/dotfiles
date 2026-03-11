{...}: {
  programs.nixvim = {
    opts = {
      # display
      number = true;
      relativenumber = true;
      signcolumn = "yes";
      termguicolors = true;

      # action
      mouse = "a";
      clipboard = "unnamedplus";
      updatetime = 200;
      timeoutlen = 300;
      undofile = true;

      # display
      wrap = false;
      scrolloff = 8;

      # search
      ignorecase = true;
      smartcase = true;

      # window split
      splitright = true;
      splitbelow = true;

      # indent
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;

      # file encoding
      encoding = "utf-8";
      fileencoding = "utf-8";
      fileencodings = "utf-8,sjis,euc-jp,iso-2022-jp";

      # invisible characters
      list = true;
      listchars = "tab:»-,trail:-,extends:»,precedes:«,nbsp:%";
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
  };
}
