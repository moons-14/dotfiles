{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "catppuccin"
      "nix"
    ];
    mutableUserSettings = false;
    mutableUserKeymaps = false;
    userKeymaps = import ./keymaps.nix;

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
      ui_font_size = 16;
      buffer_font_size = 16;
      theme = {
        mode = "dark";
        light = "Catppuccin Latte";
        dark = "Catppuccin Mocha";
      };
    };
  };
}
