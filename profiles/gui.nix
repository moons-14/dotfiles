{...}: {
  imports = [
    ./cli.nix
    ./../modules/core/niri.nix
    ./../modules/core/hyprland.nix
    ./../modules/core/greetd.nix
    ./../modules/core/noctalia.nix
    ./../modules/core/gui.nix
    ./../modules/core/kde.nix
  ];

  home-manager.users.moons.imports = [
    ./../modules/home/niri
    ./../modules/home/vscode.nix
    ./../modules/home/browser.nix
    ./../modules/home/vicinae.nix
    ./../modules/home/noctalia.nix
    ./../modules/home/avatar.nix
    ./../modules/home/ghostty
    ./../modules/home/wallpaper.nix
    ./../modules/home/lock.nix
    ./../modules/home/discord.nix
    ./../modules/home/nautilus.nix
    ./../modules/home/gtk.nix
    ./../modules/home/zoom.nix
  ];
}
