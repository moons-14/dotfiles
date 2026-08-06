{ inputs, ... }:
{
  imports = [
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    {
      pkgs,
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

            entry = "${pkgs.gitleaks}/bin/gitleaks dir --no-banner --redact --verbose .";

            pass_filenames = false;

            stages = [
              "pre-commit"
              "pre-push"
            ];
          };

          actionlint.enable = true;
          deadnix.enable = true;
          ruff.enable = true;
          statix.enable = true;
          shellcheck.enable = true;
        };
      };
    };
}
