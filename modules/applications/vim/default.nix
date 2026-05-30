{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.vim;
in
{
  imports = [
    ./system.nix
    ./home
  ];

  options.my.applications.vim = {
    enable = lib.mkEnableOption "vim text editor";
  };

  config = lib.mkIf cfg.enable {
    my.applications.vim.system.enable = lib.mkDefault true;
    my.applications.vim.homeManager.enable = lib.mkDefault true;
  };
}
