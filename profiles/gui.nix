{
  pkgs,
  userName,
  ...
}:
{
  imports = [
    ./cli-minimal.nix
    ../modules/nix/hardware/gui.nix
    ../modules/nix/camera.nix
    ../modules/nix/fonts.nix
    ../modules/nix/greetd.nix
    ../modules/nix/i18n.nix
    ../modules/nix/kde.nix
    ../modules/nix/noctalia.nix
  ];

  programs = {
    niri.enable = true;
    xwayland.enable = true;
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

  home-manager.users.${userName}.imports = [ ];
}
