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
    system.enable = lib.mkEnableOption "SSH system configuration";
    homeManager.enable = lib.mkEnableOption "SSH home-manager configuration";

    defaultIdentityFile = lib.mkOption {
      type = lib.types.str;
      default = "~/.ssh/id_ed25519";
      description = "Default SSH identity file";
    };

    addKeysToAgent = lib.mkOption {
      type = lib.types.str;
      default = "yes";
      description = "Add keys to SSH agent";
    };

    matchBlocks = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "SSH match blocks";
    };
  };

  config = lib.mkIf cfg.enable {
    my.applications.ssh.system.enable = lib.mkDefault true;
    my.applications.ssh.homeManager.enable = lib.mkDefault true;
  };
}
