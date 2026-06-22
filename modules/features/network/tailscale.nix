{ lib, config, ... }:

let
  cfg = config.my.features.network.tailscale;
in
{
  options.my.features.network.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";

    acceptDns = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Accept DNS configuration from Tailscale.";
    };

    acceptRoutes = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Accept subnet routes from Tailscale.";
    };

    advertiseRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "10.50.0.0/16" ];
      description = "Subnet routes to advertise through this machine.";
    };

    routingFeatures = lib.mkOption {
      type = lib.types.enum [
        "auto"
        "none"
        "client"
        "server"
        "both"
      ];
      default = "auto";
      description = "Override Tailscale routing features. Usually leave this as auto.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = "Override Tailscale firewall opening. Usually leave this as null.";
    };

    extraSetFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional flags to pass to `tailscale set`.";
    };

    extraUpFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional flags to pass to `tailscale up`.";
    };
  };

  config = lib.mkIf cfg.enable {
    my.applications.tailscale = {
      enable = true;

      inherit (cfg)
        acceptDns
        acceptRoutes
        advertiseRoutes
        routingFeatures
        openFirewall
        extraSetFlags
        extraUpFlags
        ;
    };
  };
}
