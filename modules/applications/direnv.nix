{ lib, config, ... }:
let
  cfg = config.my.applications.direnv;
in
{
  options.my.applications.direnv = {
    enable = lib.mkEnableOption "direnv environment variable manager";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
