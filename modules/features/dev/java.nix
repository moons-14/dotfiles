{ lib, config, ... }:
let
  cfg = config.my.features.dev.java;
in
{
  options.my.features.dev.java = {
    enable = lib.mkEnableOption "Java development environment";
  };

  config = lib.mkIf cfg.enable {
    my.applications.java.enable = true;
  };
}
