{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  mkSystem =
    {
      host,
      system,
      extraModules ? [ ],
      ...
    }:
    assert lib.assertMsg (lib.elem system config.systems)
      "mkSystem: system '${system}' not in valid systems: ${lib.generators.toPretty { } config.systems}";
    nixosSystem {
      inherit system;
      modules = [
        {
          networking.hostName = lib.mkDefault host;
        }
      ]
      ++ extraModules;
      specialArgs = { inherit inputs; };
    };
in
{
  flake.nixosConfigurations = {
    nix-example = mkSystem {
      host = "nix-example";
      system = "x86_64-linux";
      profile = "laptop";
      extraModules = [ ];
    };
  };
}
