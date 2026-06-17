{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.git.system;
in
{
  options.my.applications.git.system = {
    enable = lib.mkEnableOption "git system configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git # Distributed version control system
    ];
  };
}
