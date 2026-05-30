{ lib, config, ... }:
let
  cfg = config.my.features.connect.wifi;
in
{
  options.my.features.connect.wifi = {
    enable = lib.mkEnableOption "WiFi (NetworkManager) support";
  };

  config = lib.mkIf cfg.enable {
    my.system.network.wifi.enable = true;
  };
}
