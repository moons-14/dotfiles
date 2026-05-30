{
  config,
  lib,
  ...
}:
{
  options.my.stateVersions = {
    nixos = lib.mkOption {
      type = lib.types.str;
      default = "25.11";
    };

    homeManager = lib.mkOption {
      type = lib.types.str;
      default = "25.11";
    };
  };

  config = {
    system.stateVersion = lib.mkDefault config.my.stateVersions.nixos;
  };
}
