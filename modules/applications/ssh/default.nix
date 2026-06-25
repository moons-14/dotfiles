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
    enable = lib.mkEnableOption "OpenSSH client and agent configuration";

    defaultIdentityFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "~/.ssh/id_ed25519"
      ];
      description = ''
        Default local SSH identity files.

        These are used as the normal fallback identities when no agent key
        is accepted, or when no forwarded agent is available.
      '';
    };

    fidoIdentityFile = lib.mkOption {
      type = lib.types.str;
      default = "~/.ssh/id_ed25519_sk_rk";
      description = ''
        Local FIDO2 resident-key SSH identity handle.

        This file is only added to SSH identity candidates when a FIDO2
        device is actually visible. Do not use file existence to decide
        whether this key is usable.
      '';
    };

    githubIdentityFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Extra GitHub-specific SSH identity files.

        Leave this empty if GitHub should use the normal agent, FIDO key,
        and default identity fallback order.
      '';
    };

    addKeysToAgent = lib.mkOption {
      type = lib.types.str;
      default = "no";
      example = "1h";
      description = ''
        Value for OpenSSH AddKeysToAgent.

        Recommended default is "no" for this setup, because FIDO resident-key
        handle files should not be added to the agent accidentally.
      '';
    };

    matchBlocks = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = ''
        Additional Home Manager OpenSSH settings blocks.

        Use this for host-specific options such as ForwardAgent = true.
      '';
      example = lib.literalExpression ''
        {
          "proxmox-* *.home.arpa *.internal" = {
            ForwardAgent = true;
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    my.applications.ssh.system.enable = lib.mkDefault true;
    my.applications.ssh.homeManager.enable = lib.mkDefault true;
  };
}
