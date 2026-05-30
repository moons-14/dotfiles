_: {
  nix.settings = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://moons-dotfiles.cachix.org"
      "https://noctalia.cachix.org"
      "https://vicinae.cachix.org"
    ];

    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "moons-dotfiles.cachix.org-1:WHoroKiNScG2/dpxHHL1I0qVmvuQhJbEAP+DS2j9Rr0="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
    ];

    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
