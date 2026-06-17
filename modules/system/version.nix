{
  config,
  lib,
  ...
}:
{
  options.my.stateVersions = {
    nixos = lib.mkOption {
      type = lib.types.str;
      default = "26.05";
    };

    homeManager = lib.mkOption {
      type = lib.types.str;
      default = "26.05";
    };
  };

  config = {
    system.stateVersion = lib.mkDefault config.my.stateVersions.nixos;
  };
}
