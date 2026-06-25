{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.applications.ssh;
  hmCfg = config.my.applications.ssh.homeManager;

  hasFidoDevice = pkgs.writeShellScript "ssh-has-fido-device" ''
    ${pkgs.libfido2}/bin/fido2-token -L 2>/dev/null \
      | ${pkgs.gnugrep}/bin/grep -q .
  '';

  userMatchBlockNames = lib.attrNames (cfg.matchBlocks or { });

  userMatchBlocks = lib.mapAttrs (
    _name: value: lib.hm.dag.entryBefore [ "my-github" "my-default" ] value
  ) (cfg.matchBlocks or { });

  githubBlock = {
    header = "Host github.com";

    HostName = "github.com";
    User = "git";

    IdentityAgent = "SSH_AUTH_SOCK";

    IdentitiesOnly = false;

    ForwardAgent = false;

    AddKeysToAgent = cfg.addKeysToAgent;
  }
  // lib.optionalAttrs (cfg.githubIdentityFiles != [ ]) {
    IdentityFile = cfg.githubIdentityFiles;
  };

in
{
  options.my.applications.ssh.homeManager = {
    enable = lib.mkEnableOption "SSH home-manager configuration";
  };

  config.home-manager.sharedModules = [
    (
      { lib, ... }:
      {
        config = lib.mkIf hmCfg.enable {

          programs.ssh = {
            enable = true;
            enableDefaultConfig = false;

            settings = userMatchBlocks // {
              "my-local-fido-sk-rk" =
                lib.hm.dag.entryBefore
                  (
                    [
                      "my-github"
                      "my-default"
                    ]
                    ++ userMatchBlockNames
                  )
                  {
                    header = ''Match exec "${hasFidoDevice}"'';
                    IdentityFile = cfg.fidoIdentityFile;
                  };

              "my-github" = lib.hm.dag.entryBefore [ "my-default" ] githubBlock;

              "my-default" =
                lib.hm.dag.entryAfter
                  (
                    [
                      "my-local-fido-sk-rk"
                      "my-github"
                    ]
                    ++ userMatchBlockNames
                  )
                  {
                    header = "Host *";

                    IdentityAgent = "SSH_AUTH_SOCK";
                    IdentitiesOnly = false;

                    ForwardAgent = false;

                    IdentityFile = cfg.defaultIdentityFiles;

                    AddKeysToAgent = cfg.addKeysToAgent;

                    SetEnv = {
                      TERM = "xterm";
                    };
                  };
            };
          };
        };
      }
    )
  ];
}
