{ config, pkgs, ... }:
let
  wdisplays = pkgs.wdisplays.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ./wdisplays-canonical-scale.patch ];
  });
in
{
  programs.niri.enable = true;

  # niri-flake supplies the compositor package but does not register its
  # user units with NixOS. Without this, Ly cannot start niri-session.
  systemd.packages = [ config.programs.niri.package ];

  environment.systemPackages = [
    # Keep the transient Wayland-native GUI, with fractional scales rounded to
    # the same wl_fixed_t value that niri receives on the first Apply.
    wdisplays
    pkgs.wlr-randr # Wayland output management CLI
  ];
}
