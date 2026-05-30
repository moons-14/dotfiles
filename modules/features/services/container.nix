{ lib, config, ... }:
let
  cfg = config.my.features.services.container;
in
{
  options.my.features.services.container = {
    enable = lib.mkEnableOption "Container runtime (Docker)";
  };

  config = lib.mkIf cfg.enable {
    my.applications.docker.enable = true;
  };
}
