{...}: {
  programs.nixvim.autoCmd = [
    {
      event = "TextYankPost";
      callback.__raw = "function() vim.highlight.on_yank() end";
    }
  ];
}
