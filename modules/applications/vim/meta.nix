{ inputs, ... }:
{
  description = "Neovim configured with Nixvim";

  imports.home = [
    inputs.nixvim.homeModules.nixvim
  ];
}
