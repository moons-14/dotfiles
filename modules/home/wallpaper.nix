{
  pkgs,
  lib,
  ...
}: let
  walls = pkgs.fetchFromGitHub {
    owner = "moons-14";
    repo = "wallpapers";
    rev = "cc3256f4aaf2c8e7d16fb000b1ee251af54085db";
    hash = "sha256-emQ/FqKqMq3YI5bLx8gBZg/ZE72OG9Ilh71ggq78WdQ=";
  };
in {
  home.file.".wallpapers" = {
    source = walls;
    recursive = true;
  };

  home.file.".cache/noctalia/wallpapers.json" = {
    text = builtins.toJSON {
      defaultWallpaper = "~/.wallpapers/";
      wallpapers = {
        "DP-1" = "~/.wallpapers/";
      };
    };
  };
}
