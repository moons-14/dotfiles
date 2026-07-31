{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [ pkgs.celluloid ];

  xdg.mimeApps = {
    enable = true;
    defaultApplicationPackages = [ pkgs.celluloid ];
    defaultApplications = builtins.listToAttrs (
      map
        (mime: {
          name = mime;
          value = [ "io.github.celluloid_player.Celluloid.desktop" ];
        })
        [
          "video/3gpp"
          "video/3gpp2"
          "video/mp2t"
          "video/mp4"
          "video/mpeg"
          "video/ogg"
          "video/quicktime"
          "video/webm"
          "video/x-flv"
          "video/x-m4v"
          "video/x-matroska"
          "video/x-msvideo"
          "video/x-ms-wmv"
        ]
    );
  };
}
