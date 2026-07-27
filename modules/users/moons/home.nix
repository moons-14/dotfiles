{ primaryUser, ... }:
{
  home = {
    username = primaryUser;
    homeDirectory = "/home/${primaryUser}";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
