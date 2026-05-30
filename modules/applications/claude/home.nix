{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.claude.homeManager;
in
{
  options.my.applications.claude.homeManager = {
    enable = lib.mkEnableOption "Claude Code home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf cfg.enable {
        home.file.".claude/settings.json".text = builtins.toJSON {
          statusLine = {
            type = "command";
            command = "bun x ccusage statusline --no-offline";
            padding = 0;
          };
        };
      };
    }
  ];
}
