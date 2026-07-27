{
  nix.gc = {
    automatic = true;
    interval = [
      {
        Weekday = 7;
        Hour = 3;
        Minute = 15;
      }
    ];
    options = "--delete-older-than 14d";
  };

  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;
}
