{ lib, ... }:
{
  imports.nixos = [
    {
      options.test.nested = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    }
  ];
}
