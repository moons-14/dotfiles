{ inputs, ... }:
{
  imports = [
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    {
      config,
      ...
    }:
    {
      pre-commit.settings = {
        hooks = {
          treefmt = {
            enable = true;

            package = config.treefmt.build.wrapper;
          };

          gitleaks = {
            enable = true;
            name = "gitleaks";
            description = "Detect hardcoded secrets";

            pass_filenames = false;

            stages = [
              "pre-commit"
              "pre-push"
            ];
          };

          deadnix.enable = true;
          statix.enable = true;
          shellcheck.enable = true;
        };
      };
    };
}
