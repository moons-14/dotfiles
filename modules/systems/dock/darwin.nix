{
  lib,
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

  # Homebrew installs casks after defaults are written. Refresh the Dock only
  # after both Homebrew and Home Manager have finished activating.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    run sudo --user=${lib.escapeShellArg primaryUser} /usr/bin/killall Dock >/dev/null 2>&1 || true
  '';
}
