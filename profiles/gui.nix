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
    uwsm # Universal Wayland Session Manager (optional must be enabled)
    alacritty # A GPU Accelerated Terminal Emulator
    fuzzel # A Simple And Lightweight Application Launcher
    unstable.ghostty # A Fast And Minimal Terminal Emulator For Wayland
    xwayland-satellite # A Helper For Running X11 Applications In Wayland
    slurp # A Tool For Selecting A Region Of The Screen
    grim # A Tool For Taking Screenshots In Wayland with slurp
    wf-recorder # A Screen Recorder For Wayland
  ];

  home-manager.users.${username}.imports = [ ];
}
