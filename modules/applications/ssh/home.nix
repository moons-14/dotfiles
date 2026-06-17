{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.ssh;
  hmCfg = config.my.applications.ssh.homeManager;
in
{
  options.my.applications.ssh.homeManager = {
    enable = lib.mkEnableOption "SSH home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf hmCfg.enable {
        home.packages = [
          pkgs.openssh
        ];

        systemd.user.services.ssh-agent = {
          Unit.Description = "OpenSSH authentication agent";
          Service = {
            ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent";
          };
          Install.WantedBy = [ "default.target" ];
        };

        systemd.user.sockets.gcr-ssh-agent.Install.WantedBy = lib.mkForce [ ];

        home.sessionVariables = {
          SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/ssh-agent";
        };

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;

          settings = cfg.matchBlocks // {
            "github.com" = {
              IdentityFile = cfg.githubIdentityFiles;
              AddKeysToAgent = cfg.addKeysToAgent;
            };

            "*" = {
              IdentityFile = cfg.defaultIdentityFile;
              AddKeysToAgent = cfg.addKeysToAgent;
            };
          };
        };
      };
    }
  ];
}
