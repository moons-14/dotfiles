{
  my.features.network.tailscale = {
    enable = true;

    acceptDns = false;
    acceptRoutes = false;

    advertiseRoutes = [
      "10.50.0.0/16"
    ];
  };
}
