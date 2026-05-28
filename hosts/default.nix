{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  userName = "moons";

  mkSystem =
    {
      host,
      system,
      profile ? null,
      extraModules ? [ ],
    }:
    assert lib.assertMsg (lib.elem system config.systems)
      "mkSystem: system '${system}' not in valid systems: ${lib.generators.toPretty { } config.systems}";
    nixosSystem {
      inherit system;
      modules = [
        ./${host}/hardware-configuration.nix
        ../profiles/${profile}.nix
        ./${host}/default.nix
      ]
      ++ extraModules;
      specialArgs = { inherit inputs userName; };
    };
in
{
  flake.nixosConfigurations = {
    nix-example = mkSystem {
      host = "nix-example";
      system = "x86_64-linux";
      profile = "base";
      extraModules = [ ];
    };
  };
}
