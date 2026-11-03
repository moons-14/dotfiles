{ inputs, lib, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      configuration = inputs.nixvim.lib.evalNixvim {
        inherit system;
        modules = [
          ../modules/applications/vim/config.nix
          {
            enableMan = false;
            enablePrintInit = false;
            nixpkgs = {
              source = inputs.nixpkgs;
              config.allowUnfree = true;
            };
            env = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
              LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
            };
          }
        ];
      };
      nvim = configuration.config.build.package;
      portableInputs = inputs.nix-portable.inputs;
      portableTarget = pkgs.symlinkJoin {
        name = "moons-nvim";
        paths = [
          nvim
          # The portable runtime checks for nix beside the bundled executable.
          portableInputs.nix.packages.${system}.nix
          # Include its bootstrap Git so first launch also works offline.
          portableInputs.defaultChannel.legacyPackages.${system}.gitMinimal
        ];
        meta.mainProgram = "nvim";
      };
    in
    {
      packages = {
        inherit nvim;
      }
      //
        lib.optionalAttrs
          (builtins.elem system [
            "x86_64-linux"
            "aarch64-linux"
          ])
          {
            nvim-portable = inputs.nix-portable.packages.${system}.nix-portable.override {
              bundledPackage = portableTarget;
              compression = "zstd -9 -T2";
            };
          };
      checks.nvim = configuration.config.build.test;
    };
}
