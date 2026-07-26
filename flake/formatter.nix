{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    { system, ... }:
    let
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      treefmt = {
        projectRootFile = "flake.nix";

        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;

          shfmt.enable = true;
          shellcheck.enable = true;

          prettier = {
            enable = true;
            package = unstable.prettier;
          };
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
