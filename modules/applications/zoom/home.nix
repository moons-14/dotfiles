{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [
    (pkgs.zoom-us.override {
      # Zoom runs in an FHS environment. Include the portals there so its
      # Wayland/PipeWire screen-sharing integration can discover them.
      gnomeXdgDesktopPortalSupport = true;
    })
  ];
}
