# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  services.qemuGuest.enable = true;

  networking = {
    useDHCP = false;

    interfaces = {
      ens18 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.50.128.20";
            prefixLength = 24;
          }
        ];
      };

      ens19 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.50.7.101";
            prefixLength = 24;
          }
        ];
      };
    };

    defaultGateway = {
      address = "10.50.128.1";
      interface = "ens18";
    };

    nameservers = [
      "1.1.1.1"
    ];
  };
}
