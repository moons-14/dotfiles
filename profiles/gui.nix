{ userName, ... }:
{
  imports = [
    ./cli-minimal.nix
    ../modules/nix/hardware/gui.nix
    ../modules/nix/camera.nix
    ../modules/nix/fonts.nix
    ../modules/nix/greetd.nix
    ../modules/nix/i18n.nix
    ../modules/nix/kde.nix
  ];
  home-manager.users.${userName}.imports = [ ];
}
