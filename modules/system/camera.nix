{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.system.camera;
in
{
  options.my.system.camera = {
    enable = lib.mkEnableOption "camera support";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "uvcvideo" ];

    hardware.ipu6.enable = true;

    environment.systemPackages = with pkgs; [
      v4l-utils # Video4Linux control and diagnostics tools
      ffmpeg-full # Multimedia tools for validating camera capture pipelines
      libcamera # Camera stack and diagnostic tools for MIPI/IPU cameras
    ];

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    security.rtkit.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
