{
  username,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.nh;
in
{
  options.my.applications.nh = {
    enable = lib.mkEnableOption "nh Nix CLI helper";
  };

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      flake = "/home/${username}/dotfiles";
    };
  };
}
