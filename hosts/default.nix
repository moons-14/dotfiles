{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  username = "moons";

  mkSystem =
    {
      host,
      system,
      profiles ? [ ],
      extraModules ? [ ],
    }:
    let
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    assert lib.assertMsg (lib.elem system config.systems)
      "mkSystem: system '${system}' not in valid systems: ${lib.generators.toPretty { } config.systems}";
    nixosSystem {
      inherit system;
      modules = [
        {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = builtins.attrValues inputs.self.overlays;
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
    ops = mkSystem {
      host = "ops";
      system = "x86_64-linux";
      profiles = [
        "interfaces/cli-interactive"
        "platforms/vm"
        "workloads/remote"
      ];
    };

    internal-app-01 = mkSystem {
      host = "internal-app-01";
      system = "x86_64-linux";
      profiles = [
        "interfaces/cli-interactive"
        "platforms/vm"
        "workloads/srv"
      ];
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
        "workloads/tailscale/client"
      ];
    };

    installer = nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./installer/default.nix
      ];
      specialArgs = {
        inherit inputs;
      };
    };
  };
}
