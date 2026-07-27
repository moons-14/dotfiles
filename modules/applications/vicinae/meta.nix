{ inputs, ... }:
{
  description = "Vicinae application launcher";

  imports.home = [
    inputs.vicinae.homeManagerModules.default
  ];
}
