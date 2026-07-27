{
  inputs,
  lib,
  system,
  ...
}:
{
  imports = lib.optional (lib.hasSuffix "-darwin" system) inputs.niri-flake.homeModules.niri;
}
