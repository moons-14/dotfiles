{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.vscode.system;
in
{
  options.my.applications.vscode.system = {
    enable = lib.mkEnableOption "VSCode system configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sqlite # SQLite database library (VSCode dependency)
    ];
  };
}
