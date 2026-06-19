{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.gnupg.system;
in
{
  options.my.applications.gnupg.system = {
    enable = lib.mkEnableOption "GnuPG system configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
    };
  };
}
