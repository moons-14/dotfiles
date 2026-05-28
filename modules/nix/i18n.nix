{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        qt6Packages.fcitx5-configtool
      ];
      settings.inputMethod = {
        GroupOrder = {
          "0" = "Default";
        };
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "keyboard-jp";
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
}
