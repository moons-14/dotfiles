{ pkgs, primaryUser, ... }:
{
  home = {
    username = primaryUser;
    homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${primaryUser}" else "/home/${primaryUser}";
  };

  programs.home-manager.enable = true;
}
