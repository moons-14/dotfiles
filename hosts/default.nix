{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  userName = "moons";

  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config = {
      allowUnfree = true;
    };
  };

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
        {
          nixpkgs.config.allowUnfree = true;
        }
        ../profiles/${profile}.nix
        ./${host}/default.nix
      ]
      ++ extraModules;
      specialArgs = { inherit inputs userName unstable; };
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
