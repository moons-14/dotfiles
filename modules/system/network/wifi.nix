{
  lib,
  config,
  ...
}:
let
  cfg = config.my.system.network.wifi;
in
{
  options.my.system.network.wifi = {
    enable = lib.mkEnableOption "WiFi (NetworkManager) support";
  };

  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true;

        dns = "none";
        wifi.powersave = false;
        wifi.backend = "wpa_supplicant";
        settings = {
          "device"."wifi.scan-rand-mac-address" = "no";
          "connection"."wifi.cloned-mac-address" = "permanent";
        };
      };
      wireless.iwd.enable = false;
    };

    boot.extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom=JP
      options iwlwifi power_save=0
      options iwlwifi uapsd_disable=1
    '';

    programs.nm-applet.enable = true;
  };
}
