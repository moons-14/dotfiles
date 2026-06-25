{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

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

      ens20 = {
        useDHCP = false;
        ipv4.routes = [
          {
            address = "10.50.64.0";
            prefixLength = 24;
            via = "10.50.82.1";
          }
        ];
        ipv4.addresses = [
          {
            address = "10.50.82.10";
            prefixLength = 24;
          }
        ];
      };

    };

    defaultGateway = {
      address = "10.50.128.1";
      interface = "ens18";
    };

  };
}
