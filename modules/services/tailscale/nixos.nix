{ lib, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = lib.mkDefault false;
  };
}
