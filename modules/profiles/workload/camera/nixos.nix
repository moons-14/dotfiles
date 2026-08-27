{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gphoto2
    ffmpeg
    v4l-utils
  ];
}
