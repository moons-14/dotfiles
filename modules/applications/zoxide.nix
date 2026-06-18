{ lib, config, ... }:
let
  cfg = config.my.applications.zoxide;
in
{
  options.my.applications.zoxide = {
    enable = lib.mkEnableOption "zoxide smarter cd command";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.zoxide = {
          enable = true;
          enableZshIntegration = true;
        };
      }
    ];
  };
}
