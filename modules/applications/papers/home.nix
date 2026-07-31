{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [ pkgs.papers ];

  xdg.mimeApps = {
    enable = true;
    defaultApplicationPackages = [ pkgs.papers ];
    defaultApplications = {
      "application/pdf" = [ "org.gnome.Papers.desktop" ];
      "application/postscript" = [ "org.gnome.Papers.desktop" ];
      "application/x-bzpdf" = [ "org.gnome.Papers.desktop" ];
      "application/x-gzpdf" = [ "org.gnome.Papers.desktop" ];
      "application/x-xzpdf" = [ "org.gnome.Papers.desktop" ];
      "image/tiff" = [ "org.gnome.Papers.desktop" ];
    };
  };
}
