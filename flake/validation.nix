_: {
  perSystem =
    { pkgs, config, ... }:
    let
      script = pkgs.writeText "dotfiles-check.py" (builtins.readFile ../scripts/dotfiles-check.py);
      dotfilesCheck = pkgs.writeShellApplication {
        name = "dotfiles-check";
        runtimeInputs = [
          pkgs.git
          pkgs.nix
          pkgs.python3
        ];
        text = ''
          exec python3 ${script} "$@"
        '';
      };
    in
    {
      apps = {
        check = {
          type = "app";
          program = "${dotfilesCheck}/bin/dotfiles-check";
        };
        nix-fast-build = {
          type = "app";
          program = "${pkgs.nix-fast-build}/bin/nix-fast-build";
        };
      };

      packages = {
        dotfiles-check = dotfilesCheck;
        inherit (pkgs) nix-fast-build;
      };

      devShells.validation = config.pre-commit.devShell;

      checks = {
        validation-tool =
          pkgs.runCommand "dotfiles-check-self-test"
            {
              nativeBuildInputs = [ dotfilesCheck ];
            }
            ''
              dotfiles-check self-test
              touch "$out"
            '';

        dotnix-shell = config.devShells.dotnix;
      };
    };
}
