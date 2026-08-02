{ config, ... }:
{
  programs.niri.enable = true;

  # niri-flake supplies the compositor package but does not register its
  # user units with NixOS. Without this, Ly cannot start niri-session.
  systemd.packages = [ config.programs.niri.package ];
}
