{
  networking = {
    interfaces = {
      ens18 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.50.65.100";
            prefixLength = 24;
          }
        ];
      };

      ens19 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.50.80.100";
            prefixLength = 24;
          }
        ];
      };

      ens20 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.50.77.20";
            prefixLength = 24;
          }
        ];
      };
    };

    defaultGateway = {
      address = "10.50.80.1";
      interface = "ens19";
    };
  };
}
