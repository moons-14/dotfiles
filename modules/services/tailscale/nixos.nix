{
  services.tailscale = {
    enable = true;
    openFirewall = false;
    useRoutingFeatures = "client";
    extraSetFlags = [
      "--accept-dns=false"
      "--accept-routes=true"
    ];
  };
}
