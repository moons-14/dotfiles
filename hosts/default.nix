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

  mkNixos =
    {
      host,
      system,
      modules ? [ ],
    }:
    assert lib.assertMsg (lib.elem system config.systems)
      "mkNixos: system '${system}' not in valid systems: ${lib.generators.toPretty { } config.systems}";
    nixosSystem {
      inherit system modules;
      specialArgs = {
        inherit
          inputs
          username
          unstable
          host
          ;
      };
    };

  mkSystem =
    {
      host,
      system,
      profiles ? [ ],
      extraModules ? [ ],
    }:
    mkNixos {
      inherit host system;
      modules = [
        {
          nixpkgs.config.allowUnfree = true;
        }
        ../modules
        ./${host}/default.nix
      ]
      ++ map (p: ../profiles/${p}.nix) profiles
      ++ extraModules;
    };

  mkInstallerIso =
    {
      system,
      extraModules ? [ ],
    }:
    mkNixos {
      host = "installer-iso";
      inherit system;
      modules = [
        {
          nixpkgs.config.allowUnfree = true;
        }
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ../modules
        ./installer-iso/default.nix
      ]
      ++ extraModules;
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
    installer-iso = mkInstallerIso {
      system = "x86_64-linux";
    };

    x1g13 = mkSystem {
      host = "x1g13";
      system = "x86_64-linux";
      profiles = [
        "interfaces/gui"
        "platforms/thinkpad"
        "workloads/dev"
        "workloads/personal"
        "workloads/secure-storage"
      ];
    };
  };
}
