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
    system.enable = lib.mkEnableOption "Java system configuration";
    homeManager.enable = lib.mkEnableOption "Java home-manager configuration";
  };

  config = lib.mkIf cfg.enable {
    my.applications.java.system.enable = lib.mkDefault true;
    my.applications.java.homeManager.enable = lib.mkDefault true;
  };
}
