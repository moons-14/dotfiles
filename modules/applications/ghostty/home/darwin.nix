_: {
  # Global Ghostty keybindings are handled by the running app. Start it hidden
  # at login so Option+T and Option+Space work before opening a terminal.
  launchd.agents.ghostty-global-keybindings = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/open"
        "-gja"
        "Ghostty"
      ];
      RunAtLoad = true;
    };
  };

  programs.ghostty.package = null;
}
