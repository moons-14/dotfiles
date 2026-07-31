{ pkgs, ... }:
{
  home.packages = with pkgs; [
    clinfo
    drm_info
    libva-utils
    mesa-demos
    pciutils
    vdpauinfo
    vulkan-tools
    wayland-utils
  ];
}
