{ primaryUser, ... }:
{
  # The account already exists in macOS; declaring only its home keeps
  # nix-darwin from taking ownership of user creation and deletion.
  users.users.${primaryUser}.home = "/Users/${primaryUser}";

  nix.settings = {
    allowed-users = [ primaryUser ];
    trusted-users = [
      "root"
      primaryUser
    ];
  };

  system.defaults.dock = {
    # Finder and Trash are managed by macOS and do not belong in this list.
    persistent-apps = [
      "/Applications/Google Chrome.app"
      "/Applications/Zed.app"
      "/Applications/Visual Studio Code.app"
      "/Applications/Slack.app"
      "/Applications/Vesktop.app"
      "/Applications/Ghostty.app"
    ];
    persistent-others = [ ];
    show-recents = false;
  };
}
