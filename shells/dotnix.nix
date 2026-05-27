_: {
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      devShells.dotnix = pkgs.mkShell {
        packages = [
          config.treefmt.build.wrapper
          pkgs.gitleaks
          pkgs.git
          pkgs.pre-commit
        ];

        shellHook = config.pre-commit.settings.shellHook;
      };
    };
}
