{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.kde;
in
{
  options.my.applications.kde = {
    enable = lib.mkEnableOption "KDE Connect";
  };

  config = lib.mkIf cfg.enable {
    programs.kdeconnect = {
      enable = true;
    };
  };
}
