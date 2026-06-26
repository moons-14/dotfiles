{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.git;
in
{
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.git = {
    enable = lib.mkEnableOption "git version control";

    userName = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "moons";
      description = "Default Git user.name.";
    };

    userEmail = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "moons@moons14.com";
      description = "Default Git user.email.";
    };
  };

  config = lib.mkIf cfg.enable {
    my.applications.git.system.enable = lib.mkDefault true;
    my.applications.git.homeManager.enable = lib.mkDefault true;
  };
}
