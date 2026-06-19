{
  lib,
  config,
  ...
}:
let
  hmCfg = config.my.applications.gnupg.homeManager;
in
{
  options.my.applications.gnupg.homeManager = {
    enable = lib.mkEnableOption "GnuPG home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf hmCfg.enable {
        services.gpg-agent.enable = false;
        services.gpg-agent.enableSshSupport = false;
      };
    }
  ];
}
