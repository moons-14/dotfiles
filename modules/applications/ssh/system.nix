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
      libfido2 # FIDO2 support for SSH
    ];

    programs.ssh = {
      startAgent = true;
      agentTimeout = "24h";
    };
    programs.gnupg.agent.enableSSHSupport = lib.mkForce false;
    services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
  };
}
