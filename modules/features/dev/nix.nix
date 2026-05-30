{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.dev.nix;
in
{
  options.my.features.dev.nix = {
    enable = lib.mkEnableOption "Nix development tools (nil language server)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nil # Nix Language Server
    ];
  };
}
