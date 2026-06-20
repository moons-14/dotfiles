{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.nix-index.homeManager;
in
{
  options.my.applications.nix-index.homeManager = {
    enable = lib.mkEnableOption "nix-index home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf cfg.enable {
        programs.nix-index.enable = true;
      };
    }
  ];
}
