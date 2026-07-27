{ inputs, ... }:
{
  description = "Lanzaboote Secure Boot";

  imports.nixos = [ inputs.lanzaboote.nixosModules.lanzaboote ];
}
