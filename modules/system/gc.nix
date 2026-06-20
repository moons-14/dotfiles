_: {
  nix.gc.automatic = false;

  nix.settings.auto-optimise-store = false;

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}
