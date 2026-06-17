{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.noctalia.system;
in
{
  options.my.applications.noctalia.system = {
    enable = lib.mkEnableOption "noctalia-shell system package";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      inputs.noctalia.packages.${system}.default
    ];
  };
}
