{
  # Home Manager uses the system package set on both NixOS and nix-darwin.
  # VS Code itself is unfree, so permit it where this application is selected.
  nixpkgs.config.allowUnfree = true;
}
