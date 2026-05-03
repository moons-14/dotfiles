{...}: {
  nix.settings = {
    extra-substituters = [
      "https://moons-dotfiles.cachix.org"
      "https://noctalia.cachix.org"
    ];

    extra-trusted-public-keys = [
      "moons-dotfiles.cachix.org-1:WHoroKiNScG2/dpxHHL1I0qVmvuQhJbEAP+DS2j9Rr0="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };
}
