{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bind
    bun
    nil
    python315
    uv
  ];
}
