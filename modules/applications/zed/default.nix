{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.zed;
in
{
  imports = [
    ./home.nix
  ];

  options.my.applications.zed = {
    enable = lib.mkEnableOption "Zed code editor";
  };

  config = lib.mkIf cfg.enable {
    my.applications.zed.homeManager.enable = lib.mkDefault true;
  };
}
