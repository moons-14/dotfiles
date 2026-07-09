{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.my.applications.ghostty.system;

  system = pkgs.stdenv.hostPlatform.system;

  ghosttyPkg = inputs.ghostty.packages.${system}.ghostty-releasefast;
in
{
  options.my.applications.ghostty.system = {
    enable = lib.mkEnableOption "ghostty system configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      ghosttyPkg # A fast and minimal terminal emulator for Wayland
      ghosttyPkg.terminfo # Terminfo database for ghostty
    ];
  };
}
