{
  pkgs,
  userName,
  ...
}:
{
  imports = [
    ../modules/nix/boot
    ../modules/nix/caches.nix
    ../modules/nix/gc.nix
    ../modules/nix/hardware
    ../modules/nix/user.nix
    ../modules/nix/network
  ];

  programs = {
    zsh.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
    };
  };

  environment.systemPackages = with pkgs; [
    htop
    btop # Simple Terminal Based System Monitor
    unrar # Tool For Handling .rar Files
    unzip # Tool For Handling .zip Files
    wget # Tool For Fetching Files With Links
    curl # Tool For Fetching Files With Links
    git # Version Control System
    unstable.msedit # Microsoft Editor
  ];

  home-manager.users.${userName}.imports = [
  ];
}
