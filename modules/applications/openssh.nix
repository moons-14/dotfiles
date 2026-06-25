{ lib, config, ... }:
let
  cfg = config.my.applications.openssh;
in
{
  options.my.applications.openssh = {
    enable = lib.mkEnableOption "OpenSSH server";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PubkeyAuthentication = "yes";
      };
    };
  };
}
