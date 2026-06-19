{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.gui.password;
in
{
  options.my.features.gui.password = {
    enable = lib.mkEnableOption "GUI password manager";
  };

  config = lib.mkIf cfg.enable {
    my.applications."1password".enable = true;
  };
}
