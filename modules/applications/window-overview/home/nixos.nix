{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.window-overview.packages.${pkgs.stdenv.hostPlatform.system}.window-overview
  ];
}
