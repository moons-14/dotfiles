{ lib, pkgs, ... }:
let
  vesktop = pkgs.vesktop.overrideAttrs (oldAttrs: {
    # Electron does not enable the PipeWire WebRTC capturer in Vesktop's
    # wrapper, so Wayland compositors cannot hand screen sharing to their
    # xdg-desktop-portal backend.
    postFixup =
      builtins.replaceStrings
        [ "WaylandWindowDecorations" ]
        [ "WaylandWindowDecorations,WebRTCPipeWireCapturer" ]
        oldAttrs.postFixup;
  });
in
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  programs.vesktop = {
    enable = true;
    package = vesktop;
  };
}
