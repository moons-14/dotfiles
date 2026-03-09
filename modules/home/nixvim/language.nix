{...}: {
  programs.nixvim = {
    env = {
      LANG = "ja_JP.UTF-8";
      LC_MESSAGES = "ja_JP.UTF-8";
    };

    extraConfigLua = ''
      vim.cmd.language("ja_JP.utf8")
      vim.opt.helplang = { "ja", "en" }
    '';
  };
}
