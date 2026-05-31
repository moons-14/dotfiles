{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  username = "moons";

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
      profiles ? [ ],
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
        ../modules
        ./${host}/default.nix
      ]
      ++ map (p: ../profiles/${p}.nix) profiles
      ++ extraModules;
      specialArgs = {
        inherit
          inputs
          username
          unstable
          host
          ;
      };
    };
in
{
  flake.nixosConfigurations = {
    nix-example = mkSystem {
      host = "nix-example";
      system = "x86_64-linux";
      profiles = [
        "interfaces/cli-interactive"
        "platforms/vm"
        "workloads/dev"
        "workloads/remote"
      ];
    };
  };
}
