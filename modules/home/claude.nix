{...}: {
  home.file.".claude/settings.json".text = builtins.toJSON {
    statusLine = {
      type = "command";
      command = "claude x ccusage statusline --no-offline";
      padding = 0;
    };
  };
}
