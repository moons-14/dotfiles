{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.zoom;
  zoomX11 = pkgs.zoom-us.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];

    postFixup = (old.postFixup or "") + ''
      wrapProgram $out/bin/zoom \
        --set QT_QPA_PLATFORM xcb
    '';
  });
in
{
  options.my.applications.zoom = {
    enable = lib.mkEnableOption "Zoom video conferencing";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          zoomX11 # Video conferencing application with XWayland startup for GNOME stability
        ];
      }
    ];
  };
}
