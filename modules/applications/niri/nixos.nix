{ config, pkgs, ... }:
{
  programs.niri.enable = true;

  # niri-flake supplies the compositor package but does not register its
  # user units with NixOS. Without this, Ly cannot start niri-session.
  systemd.packages = [ config.programs.niri.package ];

  environment.systemPackages = with pkgs; [
    wdisplays # Wayland display configuration GUI
    wlr-randr # Wayland output management CLI
  ];
}
