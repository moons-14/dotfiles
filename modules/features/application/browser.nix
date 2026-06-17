{ lib, config, ... }:
let
  cfg = config.my.features.application.browser;
in
{
  options.my.features.application.browser = {
    enable = lib.mkEnableOption "Web browser (Chrome)";
  };

  config = lib.mkIf cfg.enable {
    my.applications.chrome.enable = true;
  };
}
