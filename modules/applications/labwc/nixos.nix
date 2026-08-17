{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.labwc = {
    enable = true;
    package = unstable.labwc;
  };

  xdg.portal.config.labwc.default = [
    "wlr"
    "gtk"
  ];

  # xdg-desktop-portal-wlr implements screencasting for wlroots compositors.
  # Keep it with Labwc: Niri uses xdg-desktop-portal-gnome instead.
  xdg.portal.wlr = {
    enable = true;
    settings.screencast = {
      chooser_type = "dmenu";
      chooser_cmd = "${pkgs.fuzzel}/bin/fuzzel --dmenu";
    };
  };

  # NixOS decides whether a graphical session manages graphical-session.target
  # itself by checking XDG_CURRENT_DESKTOP against a hard-coded list. Labwc is
  # currently absent from that list, so NixOS starts
  # nixos-fake-graphical-session.target before Labwc is ready.
  #
  # This configuration uses Home Manager's Labwc systemd integration, which
  # imports the Wayland environment and starts labwc-session.target correctly.
  # Mark the Labwc session as systemd-aware before the display-manager wrapper
  # performs its hard-coded check. Otherwise services such as Fcitx5 can start
  # before WAYLAND_DISPLAY is available.
  #
  # Despite the services.xserver namespace, this session wrapper is also used
  # for Wayland sessions by display managers such as Ly.
  services.xserver.displayManager.sessionCommands = lib.mkAfter ''
    case ":''${XDG_CURRENT_DESKTOP:-}:" in
      *:labwc:*)
        case ":$XDG_CURRENT_DESKTOP:" in
          *:X-NIXOS-SYSTEMD-AWARE:*)
            ;;
          *)
            export XDG_CURRENT_DESKTOP="$XDG_CURRENT_DESKTOP:X-NIXOS-SYSTEMD-AWARE"
            ;;
        esac
        ;;
    esac
  '';
}
