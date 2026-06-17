{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.java.system;
in
{
  options.my.applications.java.system = {
    enable = lib.mkEnableOption "Java system configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.java = {
      enable = true;
      package = pkgs.jdk25;
    };

    environment.systemPackages = with pkgs; [
      jdk25 # Java Development Kit 25
      maven # Java Build Tool
      gradle # Java Build Tool
    ];
  };
}
