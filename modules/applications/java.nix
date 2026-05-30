{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.java;
in
{
  options.my.applications.java = {
    enable = lib.mkEnableOption "Java runtime";
  };

  config = lib.mkIf cfg.enable {
    programs.java = {
      enable = true;
      package = pkgs.jdk25;
    };
  };
}
