{ inputs, ... }:
{
  description = "Disko declarative disk partitioning";

  imports.nixos = [ inputs.disko.nixosModules.disko ];
}
