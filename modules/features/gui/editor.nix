{ lib, config, ... }:
let
  cfg = config.my.features.gui.editor;
in
{
  options.my.features.gui.editor = {
    enable = lib.mkEnableOption "GUI code editors (VSCode and Zed)";
  };

  config = lib.mkIf cfg.enable {
    my.applications = {
      vscode.enable = true;
      zed.enable = true;
    };
  };
}
