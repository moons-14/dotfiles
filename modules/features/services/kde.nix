{ lib, config, ... }:
let
  cfg = config.my.features.services.kde;
in
{
  options.my.features.services.kde = {
    enable = lib.mkEnableOption "KDE Connect";
  };

  config = lib.mkIf cfg.enable {
    my.applications.kde.enable = true;
  };
}
