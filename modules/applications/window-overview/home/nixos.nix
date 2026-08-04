{ pkgs, ... }:
let
  windowOverview = pkgs.callPackage ../package.nix { };
in
{
  home.packages = [ windowOverview ];
}
