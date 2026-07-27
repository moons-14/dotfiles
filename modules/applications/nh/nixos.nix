{ primaryUser, ... }:
{
  programs.nh = {
    enable = true;
    flake = "/home/${primaryUser}/dotfiles";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 14d --keep 10";
    };
  };
}
