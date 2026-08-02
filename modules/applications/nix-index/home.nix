{
  inputs,
  pkgs,
  ...
}:
{
  programs.nix-index = {
    enable = true;

    package =
      inputs.nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-with-small-db;
  };
  programs.nix-index-database.comma.enable = true;
}
