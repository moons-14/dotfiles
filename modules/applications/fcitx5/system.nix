{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.fcitx5.system;
in
{
  options.my.applications.fcitx5.system = {
    enable = lib.mkEnableOption "fcitx5 system configuration";
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc-ut
          fcitx5-gtk
          kdePackages.fcitx5-qt
          qt6Packages.fcitx5-configtool
        ];
        settings.inputMethod = {
          GroupOrder = {
            "0" = "Default";
          };
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "jp";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-jp";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "mozc";
            Layout = "";
          };
        };
      };
    };
  };
}
