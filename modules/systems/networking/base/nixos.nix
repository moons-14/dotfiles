{ lib, ... }:
{
  networking.nameservers = lib.mkDefault [
    "1.1.1.1"
    "1.0.0.1"
    "10.50.80.53"
    "10.50.80.54"
  ];

  services.resolved.enable = lib.mkDefault false;
  security.pki.certificateFiles = [ ./root_ca.crt ];
}
