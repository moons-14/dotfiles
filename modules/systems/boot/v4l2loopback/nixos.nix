{ config, ... }:
{
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    kernelModules = [ "v4l2loopback" ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=42 card_label="LUMIX S9" exclusive_caps=1
    '';
  };
}
