{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.zellij;
in
{
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.zellij = {
    enable = lib.mkEnableOption "Zellij terminal multiplexer";
  };

  config = lib.mkIf cfg.enable {
    my.applications.zellij.system.enable = lib.mkDefault true;
    my.applications.zellij.homeManager.enable = lib.mkDefault true;
  };
}
