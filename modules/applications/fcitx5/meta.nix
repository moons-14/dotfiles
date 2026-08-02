{ inputs, ... }:
{
  description = "Fcitx 5 input method framework with Hazkey Japanese input";

  imports.home = [ inputs.nix-hazkey.homeModules.hazkey ];
}
