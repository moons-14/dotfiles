{ pkgs, ... }:
{
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    wdisplays # Wayland display configuration GUI
    wlr-randr # Wayland output management CLI
  ];
}
