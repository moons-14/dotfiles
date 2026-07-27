{ pkgs, ... }:
{
  boot.kernelModules = [ "uvcvideo" ];
  hardware.ipu6 = {
    enable = true;
    platform = "ipu6epmtl";
  };

  environment.systemPackages = with pkgs; [
    v4l-utils
    ffmpeg-full
    libcamera
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;
}
