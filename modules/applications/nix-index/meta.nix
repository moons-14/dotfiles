{ inputs, ... }:
{
  description = "nix-index and the comma command runner";

  imports.home = [
    inputs.nix-index-database.homeModules.default
  ];
}
