{
  networking = {
    interfaces = {
      ens18 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.50.65.11";
            prefixLength = 24;
          }
        ];
      };

      ens19 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.50.66.10";
            prefixLength = 24;
          }
        ];
      };

      ens20 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.50.77.21";
            prefixLength = 24;
          }
        ];
      };
    };

    defaultGateway = {
      address = "10.50.66.1";
      interface = "ens19";
    };
  };
}
