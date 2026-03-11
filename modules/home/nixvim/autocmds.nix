{...}: {
  programs.nixvim.autoCmd = [
    # yank highlight
    {
      event = "TextYankPost";
      callback.__raw = "function() vim.highlight.on_yank() end";
    }
  ];
}
