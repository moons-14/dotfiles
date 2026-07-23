{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.dev.dns;
in
{
  options.my.features.dev.dns = {
    enable = lib.mkEnableOption "DNS development tools (dig)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bind # DNS lookup utilities (dig, host, nslookup)
    ];
  };
}
