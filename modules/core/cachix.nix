{...}: {
  nix.settings = {
    extra-substituters = [
      "https://moons-dotfiles.cachix.org"
    ];

    extra-trusted-public-keys = [
      "moons-dotfiles.cachix.org-1:WHoroKiNScG2/dpxHHL1I0qVmvuQhJbEAP+DS2j9Rr0="
    ];
  };
}
