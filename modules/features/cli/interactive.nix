{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.cli.interactive;
in
{
  options.my.features.cli.interactive = {
    enable = lib.mkEnableOption "Interactive CLI tools (vim, btop, zellij)";
  };

  config = lib.mkIf cfg.enable {
    my.applications = {
      vim.enable = true;
      zellij.enable = true;
    };

    environment.systemPackages = with pkgs; [
      tio # A Simple TTY Terminal I/O Application
    ];
  };
}
