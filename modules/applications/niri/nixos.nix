{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.niri = {
    enable = true;
    package = inputs.niri-flake.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
  };

  # niri-flake supplies the compositor package but does not register its
  # user units with NixOS. Without this, Ly cannot start niri-session.
  systemd.packages = [ config.programs.niri.package ];
}
