{ lib, ... }:
{
  services.tailscale = {
    useRoutingFeatures = lib.mkForce "client";
    extraSetFlags = lib.mkForce [
      "--accept-dns=true"
      "--accept-routes=true"
    ];
  };
}
