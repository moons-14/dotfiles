{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.java;
in
{
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.java = {
    enable = lib.mkEnableOption "Java runtime";
  };

  config = lib.mkIf cfg.enable {
    my.applications.java.system.enable = lib.mkDefault true;
    my.applications.java.homeManager.enable = lib.mkDefault true;
  };
}
