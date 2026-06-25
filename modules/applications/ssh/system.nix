{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.ssh.system;
in
{
  options.my.applications.ssh.system = {
    enable = lib.mkEnableOption "SSH system configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      openssh # OpenSSH client and server
    ];

    programs.ssh.startAgent = false;
    services.gnome.gcr-ssh-agent.enable = false;
  };
}
