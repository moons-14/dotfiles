{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    extra-allowed-users = [
      "nixdeploy"
    ];

    connect-timeout = 10;

    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://moons-dotfiles.cachix.org"
      "https://noctalia.cachix.org"
      "https://vicinae.cachix.org"
      "https://ghostty.cachix.org"
      "https://cache.numtide.com"
      "https://codex-desktop-linux.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];

    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "moons-dotfiles.cachix.org-1:WHoroKiNScG2/dpxHHL1I0qVmvuQhJbEAP+DS2j9Rr0="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "codex-desktop-linux.cachix.org-1:nX/xy6AdK9hQE24A8ALGjkCKj2ObFmcnemiL5Cid4nk="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-builder-1:nix-builder-1:aG/Y2Lac517isxGO+ZYdVgglj/SI54PkkWoZTQI9aOI="
    ];
  };
}
