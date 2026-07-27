{ lib, ... }:
{
  services.tailscale = {
    useRoutingFeatures = lib.mkForce "server";
    extraSetFlags = lib.mkForce [
      "--accept-dns=false"
      "--accept-routes=false"
      "--advertise-routes=10.50.0.0/16"
    ];
  };
}
