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
      type = lib.types.str;
      default = "moons-14";
      description = "Git user name";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "moons@moons14.com";
      description = "Git user email";
    };
  };

  config = lib.mkIf cfg.enable {
    my.applications.git.system.enable = lib.mkDefault true;
    my.applications.git.homeManager.enable = lib.mkDefault true;
  };
}
