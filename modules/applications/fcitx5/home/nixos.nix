{ pkgs, ... }:
{

  services.hazkey.enable = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;

      addons = with pkgs; [
        fcitx5-gtk
        kdePackages.fcitx5-qt
        qt6Packages.fcitx5-configtool
      ];

      settings = {
        inputMethod = {
          GroupOrder."0" = "Default";

          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "jp";
            DefaultIM = "hazkey";
          };

          "Groups/0/Items/0" = {
            Name = "keyboard-jp";
          };

          "Groups/0/Items/1" = {
            Name = "hazkey";
          };
        };

        globalOptions = {
          Hotkey = {
            EnumerateWithTriggerKeys = false;
            AltTriggerKeys = "";
            EnumerateSkipFirst = false;
            ModifierOnlyKeyTimeout = 250;
          };

          "Hotkey/TriggerKeys"."1" = "Zenkaku_Hankaku";
          "Hotkey/ActivateKeys"."0" = "Henkan";
          "Hotkey/DeactivateKeys"."0" = "Muhenkan";
          "Hotkey/PrevPage"."0" = "Up";
          "Hotkey/NextPage"."0" = "Down";
          "Hotkey/PrevCandidate"."0" = "Shift+Tab";
          "Hotkey/NextCandidate"."0" = "Tab";
          "Hotkey/TogglePreedit"."0" = "Control+Alt+P";

          Behavior = {
            ActiveByDefault = false;
            resetStateWhenFocusIn = "No";
            ShareInputState = "No";
            PreeditEnabledByDefault = true;
            ShowInputMethodInformation = true;
            showInputMethodInformationWhenFocusIn = false;
            CompactInputMethodInformation = true;
            ShowFirstInputMethodInformation = true;
            DefaultPageSize = 5;
            OverrideXkbOption = false;
            CustomXkbOption = "";
            EnabledAddons = "";
            DisabledAddons = "";
            PreloadInputMethod = true;
            AllowInputMethodForPassword = false;
            ShowPreeditForPassword = false;
            AutoSavePeriod = 30;
          };
        };
      };
    };
  };
}
