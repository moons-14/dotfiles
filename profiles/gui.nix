{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./cli-minimal.nix
    ../modules/system/hardware/gui.nix
    ../modules/system/camera.nix
    ../modules/system/fonts.nix
    ../modules/applications/greetd.nix
    ../modules/applications/fcitx5.nix
    ../modules/applications/kde.nix
  ];

  my.applications = {
    niri.enable = true;
    noctalia.enable = true;
    wayland.enable = true;
  };

  programs = {
    dconf.enable = true;
    seahorse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    tuigreet # The Login Manager (Sometimes Referred To As Display Manager)
    fuzzel # A Simple And Lightweight Application Launcher
  ];

  home-manager.users.${username}.imports = [ ];
}
