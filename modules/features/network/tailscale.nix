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
    my.applications.tailscale = {
      enable = true;
      inherit (cfg) acceptDns acceptRoutes extraUpFlags;
    };
  };
}
