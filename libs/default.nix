{
  inputs,
  lib ? inputs.nixpkgs.lib,
  root,
}:
let
  registry = import ./registry.nix {
    inherit inputs lib;
    modulesRoot = root + "/modules";
  };
  hosts = import ./hosts.nix {
    inherit inputs lib registry;
  };
in
{
  inherit hosts registry;
}
