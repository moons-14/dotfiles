{
  services.resolved = {
    enable = true;
    settings.Resolve.FallbackDNS = [ "1.1.1.1" ];
  };

  security.pki.certificateFiles = [
    ./root_ca.crt
  ];
}
