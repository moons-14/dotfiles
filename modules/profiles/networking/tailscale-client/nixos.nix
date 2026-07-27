{ lib, ... }:
{
  services.tailscale = {
    useRoutingFeatures = lib.mkForce "client";
    extraSetFlags = lib.mkForce [
      "--accept-dns=false"
      "--accept-routes=true"
    ];
  };
}
