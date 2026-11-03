_: {
  env = {
    LANG = "ja_JP.UTF-8";
  };

  extraConfigLua = ''
    -- Set this after the wrapper has exported LOCALE_ARCHIVE.
    vim.env.LC_MESSAGES = "ja_JP.UTF-8"
    vim.cmd.language("ja_JP.utf8")
    vim.opt.helplang = { "ja", "en" }
  '';
}
