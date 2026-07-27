{ lib, ... }:
{
  description = "alpha test application";

  includes = [ "services.nested" ];

  imports.nixos = [
    {
      options.test = {
        external = lib.mkOption {
          type = lib.types.str;
          default = "external-default";
        };
        systemValues = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      };
    }
  ];

  imports.darwin = [
    {
      options.test.systemValues = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    }
  ];

  imports.home = [
    {
      options.test.homeValues = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    }
  ];
}
