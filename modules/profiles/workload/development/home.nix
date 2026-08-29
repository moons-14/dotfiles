{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bind
    bun
    nil
    python314
    uv
  ];
}
