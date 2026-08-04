{ inputs, pkgs, ... }:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [ unstable.wl-find-cursor ];
}
