{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [ pkgs.loupe ];

  xdg.mimeApps = {
    enable = true;
    defaultApplicationPackages = [ pkgs.loupe ];
    defaultApplications = builtins.listToAttrs (
      map
        (mime: {
          name = mime;
          value = [ "org.gnome.Loupe.desktop" ];
        })
        [
          "image/avif"
          "image/bmp"
          "image/gif"
          "image/heic"
          "image/heif"
          "image/jpeg"
          "image/jxl"
          "image/png"
          "image/svg+xml"
          "image/webp"
        ]
    );
  };
}
