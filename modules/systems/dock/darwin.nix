{
  primaryUser,
  ...
}:
{
  system.defaults.dock = {
    # Finder and Trash are managed by macOS and do not belong in this list.
    persistent-apps = [
      "/Applications/Google Chrome.app"
      "/Users/${primaryUser}/Applications/Home Manager Apps/Zed.app"
      "/Users/${primaryUser}/Applications/Home Manager Apps/Visual Studio Code.app"
      "/Applications/Slack.app"
      "/Applications/Vesktop.app"
      "/Applications/Ghostty.app"
      "/Applications/ChatGPT.app"
    ];
    persistent-others = [ ];
    autohide = true;
    minimize-to-application = true;
    mru-spaces = false;
    expose-group-apps = false;
    show-recents = false;
  };
}
