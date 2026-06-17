{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.greetd;
in
{
  options.my.applications.greetd = {
    enable = lib.mkEnableOption "greetd login manager";
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          user = "greeter";
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        };
      };
    };
  };
}
