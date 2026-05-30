{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.zsh;
in
{
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.zsh = {
    enable = lib.mkEnableOption "Zsh shell";
    system.enable = lib.mkEnableOption "Zsh system configuration";
    homeManager.enable = lib.mkEnableOption "Zsh home-manager configuration";
  };

  config = lib.mkIf cfg.enable {
    my.applications.zsh.system.enable = lib.mkDefault true;
    my.applications.zsh.homeManager.enable = lib.mkDefault true;
  };
}
