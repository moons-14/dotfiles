{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.my.drivers.intel;
in
{
  options.my.drivers.intel = {
    enable = lib.mkEnableOption "Intel Graphics Drivers";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      extraPackages = with pkgs; [
        intel-media-driver # Intel Media Driver for VA-API
        intel-vaapi-driver # VA-API Intel driver
        vaapiVdpau # VA-API to VDPAU adapter
        libvdpau-va-gl # VDPAU driver with OpenGL/VAAPI backend
      ];
    };
  };
}
