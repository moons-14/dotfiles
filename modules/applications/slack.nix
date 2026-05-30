{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.slack;
in
{
  options.my.applications.slack = {
    enable = lib.mkEnableOption "Slack messaging client";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "slack";

    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          slack # Team messaging and collaboration platform
        ];
      }
    ];
  };
}
