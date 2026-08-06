{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bind
    bun
    mcp-nixos
    nix-fast-build
    nix-tree
    nixd
    python312
    uv
  ];
}
