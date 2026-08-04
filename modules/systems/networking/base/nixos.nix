{ lib, ... }:
let
  dohPort = 5300;

  dohLocalUpstream = "127.0.0.1#${toString dohPort}";

  internalDns = [
    "10.50.80.53"
    "10.50.80.54"

    # "fd00:50:80::53"
    # "fd00:50:80::54"
  ];

  internalZones = [
    "app.homelabs.run"
  ];

  internalDnsServers = lib.concatMap (zone: map (dns: "/${zone}/${dns}") internalDns) internalZones;
in
{
  services.resolved.enable = false;

  networking.networkmanager.dns = "none";

  services.dnscrypt-proxy = {
    enable = true;

    upstreamDefaults = true;

    settings = {
      listen_addresses = [
        "127.0.0.1:${toString dohPort}"
      ];

      server_names = [
        "cloudflare"
        "cloudflare-ipv6"
      ];

      ipv4_servers = true;
      ipv6_servers = true;

      dnscrypt_servers = false;
      doh_servers = true;
      odoh_servers = false;

      cache = false;

      block_ipv6 = false;

      ignore_system_dns = true;

      bootstrap_resolvers = [
        "9.9.9.11:53"
        "149.112.112.11:53"
        "[2620:fe::11]:53"
        "[2620:fe::fe:11]:53"
      ];

      netprobe_address = "1.1.1.1:443";

      timeout = 5000;
      keepalive = 30;
    };
  };

  services.dnsmasq = {
    enable = true;

    resolveLocalQueries = true;

    settings = {
      no-resolv = true;

      local-service = "host";

      server = [ dohLocalUpstream ] ++ internalDnsServers;

      all-servers = true;

      cache-size = 10000;

      dns-loop-detect = true;
      domain-needed = true;
      bogus-priv = true;
    };
  };

  systemd.services.dnsmasq = {
    wants = [ "dnscrypt-proxy.service" ];
    after = [ "dnscrypt-proxy.service" ];
  };

  security.pki.certificateFiles = [
    ./root_ca.crt
  ];
}
