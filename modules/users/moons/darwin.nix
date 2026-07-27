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
}
