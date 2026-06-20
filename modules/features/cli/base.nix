{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.features.cli.base;
in
{
  options.my.features.cli.base = {
    enable = lib.mkEnableOption "Base CLI configuration";
    sshServer = lib.mkEnableOption "OpenSSH server";
  };

  config = lib.mkIf cfg.enable {
    my.applications = {
      btop.enable = true;
      git.enable = true;
      ssh.enable = true;
      direnv.enable = true;
      gnupg.enable = true;
      nh.enable = true;
      nix-index.enable = true;
      openssh.enable = cfg.sshServer;
    };

    environment.systemPackages = with pkgs; [
      htop # Interactive Process Viewer
      fastfetch # Fast system information tool
      curl # Tool For Fetching Files With Links
      wget # Tool For Fetching Files With Links
      unzip # Tool For Handling .zip Files
      unrar # Tool For Handling .rar Files
      ripgrep # Fast Search Tool
    ];
  };
}
