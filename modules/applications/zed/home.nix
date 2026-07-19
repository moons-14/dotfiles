{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.zed.homeManager;
in
{
  options.my.applications.zed.homeManager = {
    enable = lib.mkEnableOption "Zed home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf cfg.enable {
        programs.zed-editor = {
          enable = true;
          mutableUserSettings = false;

          userSettings = {
            agent = {
              flexible = true;
              favorite_models = [ ];
              model_parameters = [ ];
            };

            project_panel.dock = "left";

            telemetry = {
              diagnostics = false;
              metrics = false;
            };

            vim_mode = true;

            agent_servers = {
              github-copilot-cli.type = "registry";
              codex-acp.type = "registry";
              claude-acp.type = "registry";
            };

            icon_theme = {
              mode = "dark";
              light = "Zed (Default)";
              dark = "Zed (Default)";
            };

            ui_font_size = 18;
            buffer_font_size = 20;

            theme = {
              mode = "dark";
              light = "Dracula";
              dark = "Dracula";
            };
          };
        };
      };
    }
  ];
}
