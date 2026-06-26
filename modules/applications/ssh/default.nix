{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.ssh;
in
{
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.ssh = {
    enable = lib.mkEnableOption "OpenSSH client";
  };

  config = lib.mkIf cfg.enable {
    my.applications.ssh.system.enable = lib.mkDefault true;
    my.applications.ssh.homeManager.enable = lib.mkDefault true;
  };
}
