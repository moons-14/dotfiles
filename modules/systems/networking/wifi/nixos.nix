{
  networking = {
    networkmanager = {
      enable = true;
      dns = "none";
      wifi = {
        powersave = false;
        backend = "wpa_supplicant";
      };
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
}
