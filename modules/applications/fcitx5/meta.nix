{ inputs, ... }:
{
  description = "Fcitx 5 input method framework with Hazkey Japanese input";

  imports.nixos = [ inputs.nix-hazkey.nixosModules.hazkey ];
}
