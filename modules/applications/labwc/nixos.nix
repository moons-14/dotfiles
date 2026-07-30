{ inputs, pkgs, ... }:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.labwc = {
    enable = true;
    package = unstable.labwc;
  };

  xdg.portal.config.labwc.default = [
    "wlr"
    "gtk"
  ];

  environment.systemPackages = [
    pkgs.wdisplays
    pkgs.wlr-randr
  ];
}
