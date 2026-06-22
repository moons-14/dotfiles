{ lib, config, ... }:

let
  cfg = config.my.applications.tailscale;

  hasAdvertiseRoutes = cfg.advertiseRoutes != [ ];

  computedRoutingFeatures =
    if cfg.routingFeatures != "auto" then
      cfg.routingFeatures
    else if hasAdvertiseRoutes && cfg.acceptRoutes then
      "both"
    else if hasAdvertiseRoutes then
      "server"
    else if cfg.acceptRoutes then
      "client"
    else
      "none";

  computedOpenFirewall = if cfg.openFirewall != null then cfg.openFirewall else hasAdvertiseRoutes;

  computedSetFlags = [
    "--accept-dns=${lib.boolToString cfg.acceptDns}"
    "--accept-routes=${lib.boolToString cfg.acceptRoutes}"
  ]
  ++ lib.optionals hasAdvertiseRoutes [
    "--advertise-routes=${lib.concatStringsSep "," cfg.advertiseRoutes}"
  ]
  ++ cfg.extraSetFlags;
in
{
  options.my.applications.tailscale = {
    enable = lib.mkEnableOption "Tailscale";

    acceptDns = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Accept DNS configuration from Tailscale.";
    };

    acceptRoutes = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Accept subnet routes advertised by other Tailscale nodes.";
    };

    advertiseRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "10.50.0.0/16" ];
      description = "Subnet routes to advertise through this Tailscale node.";
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
      description = ''
        Routing feature mode for Tailscale.

        auto:
          - advertiseRoutes only -> server
          - acceptRoutes only -> client
          - both -> both
          - neither -> none
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = ''
        Whether to open the firewall for Tailscale's UDP port.

        null means automatic:
          - true when advertiseRoutes is non-empty
          - false otherwise
      '';
    };

    extraSetFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional flags to pass to `tailscale set`.";
    };

    extraUpFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Additional flags to pass to `tailscale up`.

        Note: on current NixOS this is only applied by the built-in
        autoconnect service when services.tailscale.authKeyFile is set.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;

      openFirewall = computedOpenFirewall;
      useRoutingFeatures = computedRoutingFeatures;

      # 常時反映したい設定は tailscale set に寄せる
      extraSetFlags = computedSetFlags;

      # authKeyFile を使う場合だけ効くものとして残す
      inherit (cfg) extraUpFlags;
    };
  };
}
