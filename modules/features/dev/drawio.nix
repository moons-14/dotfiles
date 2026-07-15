{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.dev.drawio;
in
{
  options.my.features.dev.drawio = {
    enable = lib.mkEnableOption "Draw.io diagram editor";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      drawio # Diagram editor
    ];
  };
}
