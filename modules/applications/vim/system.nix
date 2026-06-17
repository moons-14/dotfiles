{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.vim.system;
in
{
  options.my.applications.vim.system = {
    enable = lib.mkEnableOption "vim system configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vim # Highly configurable text editor
    ];

    environment.variables.EDITOR = "nvim";
  };
}
