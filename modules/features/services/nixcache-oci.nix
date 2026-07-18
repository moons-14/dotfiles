{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.services.nixcacheOci;
in
{
  options.my.features.services.nixcacheOci = {
    enable = lib.mkEnableOption "Nix binary cache backed by public GHCR";
  };

  config = lib.mkIf cfg.enable {
    my.system.nixcacheOci.enable = true;
  };
}
