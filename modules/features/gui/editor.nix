{ lib, config, ... }:
let
  cfg = config.my.features.gui.editor;
in
{
  options.my.features.gui.editor = {
    enable = lib.mkEnableOption "GUI code editor (VSCode)";
  };

  config = lib.mkIf cfg.enable {
    my.applications.vscode.enable = true;
  };
}
