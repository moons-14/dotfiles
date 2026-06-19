{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.gnupg;
in
{
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.gnupg = {
    enable = lib.mkEnableOption "GnuPG agent";
  };

  config = lib.mkIf cfg.enable {
    my.applications.gnupg.system.enable = lib.mkDefault true;
    my.applications.gnupg.homeManager.enable = lib.mkDefault true;
  };
}
