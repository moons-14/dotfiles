{ pkgs, ... }:
{
  boot.kernelModules = [ "uvcvideo" ];

  environment.systemPackages = with pkgs; [
    v4l-utils
    (ffmpeg-full)
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
}