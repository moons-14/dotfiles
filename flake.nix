{
  description = "moons nix configurations and development shells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae.url = "github:vicinaehq/vicinae";
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty.url = "github:ghostty-org/ghostty";
    niri-flake.url = "github:sodiboo/niri-flake";

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-hardware,
    home-manager,
    ...
  }: let
    mkSystem = {
      host,
      system,
      profile,
      extraModules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit host;
          inherit profile;
        };
        modules =
          [
            ./overlays
            ./modules/core
            ./profiles/${profile}.nix
            ./hosts/${host}
          ]
          ++ extraModules;
      };
  in {
    nixosConfigurations = {
      x1g9 = mkSystem {
        host = "x1g9";
        system = "x86_64-linux";
        profile = "laptop";
        extraModules = [];
      };
      x1g13-wsl = mkSystem {
        host = "x1g13-wsl";
        system = "x86_64-linux";
        profile = "cli";
        extraModules = [];
      };
      x1g13 = mkSystem {
        host = "x1g13";
        system = "x86_64-linux";
        profile = "laptop";
        extraModules = [];
      };
      monitor = mkSystem {
        host = "monitor";
        system = "x86_64-linux";
        profile = "cli-server";
        extraModules = [];
      };
      dev-1 = mkSystem {
        host = "dev-1";
        system = "x86_64-linux";
        profile = "cli-server";
        extraModules = [];
      };
      service-1 = mkSystem {
        host = "service-1";
        system = "x86_64-linux";
        profile = "cli-server";
        extraModules = [];
      };
    };

    devShells = {
      x86_64-linux = let
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) ["ngrok"];
        };
      in {
        next-web = import ./shells/next-web.nix {inherit pkgs;};
        jupyter = import ./shells/jupyter.nix {inherit pkgs;};
        rust = import ./shells/rust/default.nix {inherit pkgs;};
      };
    };
  };
}
