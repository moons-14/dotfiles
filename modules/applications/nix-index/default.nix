{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.nix-index;
in
{
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.nix-index = {
    enable = lib.mkEnableOption "nix-index and comma command runner";
  };

  config = lib.mkIf cfg.enable {
    my.applications.nix-index.system.enable = lib.mkDefault true;
    my.applications.nix-index.homeManager.enable = lib.mkDefault true;
  };
}
