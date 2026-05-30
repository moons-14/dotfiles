{ lib, config, ... }:
let
  cfg = config.my.features.application.communication;
in
{
  options.my.features.application.communication = {
    enable = lib.mkEnableOption "Communication applications (Discord, Zoom, Slack)";
  };

  config = lib.mkIf cfg.enable {
    my.applications = {
      discord.enable = true;
      zoom.enable = true;
      slack.enable = true;
    };
  };
}
