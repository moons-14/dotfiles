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

          pkgs.git
          pkgs.gitleaks
          pkgs.pre-commit

          # sops-nix / age
          pkgs.sops
          pkgs.age
          pkgs.ssh-to-age

          # YubiKey for sops editing
          pkgs.age-plugin-yubikey
          pkgs.yubikey-manager
          pkgs.pcsc-tools
        ];

        shellHook = ''
          ${config.pre-commit.settings.shellHook}

          export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/yubikey-identity.txt"
        '';
      };
    };
}
