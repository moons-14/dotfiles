{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bind
    bun
    nil
    python312
    uv
  ];
}
