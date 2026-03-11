{...}: {
  home.file.".claude/settings.json".text = builtins.toJSON {
    statusLine = {
      type = "command";
      command = "bun x ccusage statusline --no-offline";
      padding = 0;
    };
  };
}
