{ host, pkgs, ... }:
{
  networking = {
    hostName = "${host}";
    nameservers = [
      "127.0.0.1"
      "::1"
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

  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      doh_servers = false;
      dnscrypt_servers = false;

      server_names = [ "moons14-plain" ];
      static."moons14-plain".stamp = "sdns://AAAAAAAAAAAACzE3Mi4zMS4zMC4y";

      ignore_system_dns = true;
      listen_addresses = [
        "127.0.0.1:53"
        "[::1]:53"
      ];
    };
  };
}
