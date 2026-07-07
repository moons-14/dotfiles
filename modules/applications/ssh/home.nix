{
  pkgs,
  lib,
  config,
  ...
}:
let
  hmCfg = config.my.applications.ssh.homeManager;
in
{
  options.my.applications.ssh.homeManager = {
    enable = lib.mkEnableOption "SSH home-manager configuration";

    matchBlocks = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "SSH match blocks";
    };
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf hmCfg.enable {
        home.packages = [
          pkgs.openssh
        ];

        systemd.user.sockets.gcr-ssh-agent.Install.WantedBy = lib.mkForce [ ];

        services.ssh-agent.enable = lib.mkForce false;

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;

          settings = hmCfg.matchBlocks // {
            "github.com" = {
              HostName = "github.com";
              User = "git";
              AddKeysToAgent = "no";
            };

            "*.sfc.wide.ad.jp" = {
              identityFile = "~/.ssh/id_ed25519_sk_rk";
              identitiesOnly = true;
            };
            "*" = {
              AddKeysToAgent = "no";
              SetEnv = {
                TERM = "xterm-256color";
              };
            };
          };

          extraConfig = ''
            Match exec "test -S %d/.1password/agent.sock"
              IdentityAgent %d/.1password/agent.sock
          '';
        };
      };
    }
  ];
}
