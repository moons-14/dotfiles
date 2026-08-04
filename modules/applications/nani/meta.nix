{ inputs, ... }:
{
  description = "Nani Translate application";

  imports.home = [
    inputs.nani-translate-linux.homeManagerModules.default
  ];
}
