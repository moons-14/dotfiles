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

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;

          matchBlocks = cfg.matchBlocks // {
            "*" = {
              identityFile = cfg.defaultIdentityFile;
              extraOptions.AddKeysToAgent = cfg.addKeysToAgent;
            };
          };
        };
      };
    }
  ];
}
