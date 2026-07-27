{ primaryUser, ... }:
{
  home = {
    username = primaryUser;
    homeDirectory = "/home/${primaryUser}";
  };

  programs.home-manager.enable = true;
}
