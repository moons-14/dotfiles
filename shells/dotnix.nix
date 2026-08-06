_: {
  perSystem =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      devShells.dotnix = pkgs.mkShell {
        packages = [
          config.treefmt.build.wrapper
          config.packages.dotfiles-check

          pkgs.actionlint
          pkgs.git
          pkgs.gitleaks
          pkgs.mcp-nixos
          pkgs.nix-fast-build
          pkgs.nix-tree
          pkgs.nixd
          pkgs.pre-commit

          # sops-nix / age
          pkgs.sops
          pkgs.age
          pkgs.ssh-to-age

          # YubiKey for sops editing
          pkgs.age-plugin-yubikey
          pkgs.yubikey-manager
        ]
        ++ lib.optionals pkgs.stdenv.isLinux [
          pkgs.pcsc-tools
        ];

        shellHook = ''
          ${config.pre-commit.settings.shellHook}

          export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/yubikey-identity.txt"
        '';
      };
    };
}
