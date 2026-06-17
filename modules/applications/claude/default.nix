{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.claude;
in
{
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.claude = {
    enable = lib.mkEnableOption "Claude Code AI assistant";
  };

  config = lib.mkIf cfg.enable {
    my.applications.claude.system.enable = lib.mkDefault true;
    my.applications.claude.homeManager.enable = lib.mkDefault true;
  };
}
