{ lib, config, ... }:
let
  cfg = config.my.applications.tailscale;
in
{
  options.my.applications.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";

    acceptDns = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Accept DNS configuration from Tailscale";
    };

    acceptRoutes = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Accept subnet routes from Tailscale";
    };

    extraUpFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional flags to pass to tailscale up";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      extraUpFlags = [
        "--accept-dns=${if cfg.acceptDns then "true" else "false"}"
      ]
      ++ lib.optional cfg.acceptRoutes "--accept-routes"
      ++ cfg.extraUpFlags;
    };
  };
}
