{ pkgs, lib, ... }:
let
  walls = pkgs.fetchFromGitHub {
    owner = "moons-14";
    repo  = "wallpapers";
    rev   = "cc3256f4aaf2c8e7d16fb000b1ee251af54085db";
    hash  = "sha256-/Q8tiV7iegm366/7sfJv2ze7rRNriaQilvpK+91krVY=";
  };
in {
  home.file.".wallpapers" = {
    source = walls;
    recursive = true;
  };
}
