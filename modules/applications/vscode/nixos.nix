{ pkgs, ... }:
{
  nixpkgs.overlays = [ (import ../../../overlays/vscode.nix) ];

  environment.systemPackages = [ pkgs.sqlite ];
}
