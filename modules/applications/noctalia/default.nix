{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.noctalia;
in
{
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.noctalia = {
    enable = lib.mkEnableOption "noctalia-shell";
  };

  config = lib.mkIf cfg.enable {
    my.applications.noctalia.system.enable = lib.mkDefault true;
    my.applications.noctalia.homeManager.enable = lib.mkDefault true;
  };
}
