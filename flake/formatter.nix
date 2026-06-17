{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = _: {
    treefmt = {
      projectRootFile = "flake.nix";

      programs = {
        nixfmt.enable = true;
        deadnix.enable = true;
        statix.enable = true;

        shfmt.enable = true;
        shellcheck.enable = true;

        prettier.enable = true;
        yamlfmt.enable = true;
        taplo.enable = true;
        oxfmt.enable = true;
      };

      settings = {
        excludes = [
          ".git/**"
          "*.lock"
          ".direnv/**"
          "*.age"
        ];
      };
    };
  };
}
