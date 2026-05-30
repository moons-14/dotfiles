{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.vscode;
in
{
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.vscode = {
    enable = lib.mkEnableOption "Visual Studio Code editor";
  };

  config = lib.mkIf cfg.enable {
    my.applications.vscode.system.enable = lib.mkDefault true;
    my.applications.vscode.homeManager.enable = lib.mkDefault true;
  };
}
