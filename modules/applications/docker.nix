{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.docker;
in
{
  options.my.applications.docker = {
    enable = lib.mkEnableOption "Docker container runtime";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      daemon.settings = {
        ipv6 = true;
        "fixed-cidr-v6" = "fd00:30::/64";
        ip6tables = true;
      };
    };

    environment.systemPackages = with pkgs; [
      docker # Container runtime
      oxker # Docker TUI Tool
    ];
  };
}
