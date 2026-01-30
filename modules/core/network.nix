{ host, pkgs, ... }:
{
  networking = {
    hostName = "${host}";
    nameservers = [
      "172.31.30.2"
      "fd12:3456:789a:30::53"
    ];

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

  services.resolved.enable = false;

  environment.systemPackages = [ pkgs.networkmanagerapplet ];
  programs.nm-applet.enable = true;

  security.pki.certificateFiles = [ ./ca/root_ca.crt ];

}
