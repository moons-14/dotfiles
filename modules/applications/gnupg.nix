{ lib, config, ... }:
let
  cfg = config.my.applications.gnupg;
in
{
  options.my.applications.gnupg = {
    enable = lib.mkEnableOption "GnuPG agent";
  };

  config = lib.mkIf cfg.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
    };
  };
}
