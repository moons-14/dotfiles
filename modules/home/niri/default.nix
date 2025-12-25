{ inputs, pkgs, ... }:
let
  defaultKeyBind = import ./defaultKeyBind.nix;
in
{
  imports = [ inputs.niri-flake.homeModules.niri ];
  programs.niri.package = pkgs.niri;

  programs.niri.settings = {
    input.touchpad = {
      natural-scroll = true;
      scroll-factor = 4.0;
      scroll-method = "two-finger";
      click-method = "clickfinger";
      drag = true;
      drag-lock = true;
    };

    spawn-at-startup = [
      { command = [ "noctalia-shell" ]; }
    ];

    outputs."eDP-1".scale = 1;
    cursor.size = 16;

    # Doracura color
    layout = {
      focus-ring = {
        active.color = "#bd93f9";
        inactive.color = "#6272a4";
      };
      border = {
        active.color = "#ffc87f";
        inactive.color = "#505050";
        urgent.color = "#9b0000";
      };
      shadow = {
        color = "#0007";
      };
    };

    binds = defaultKeyBind // {
      "Mod+T" = {
        action.spawn = "ghostty";
        hotkey-overlay.title = "Open a Terminal: ghostty";
      };
      "Mod+D" = {
        action.spawn = [
          "vicinae"
          "toggle"
        ];
        hotkey-overlay.title = "Run an Application: vicinae";
      };
      "Mod+Space" = {
        action.spawn = [
          "vicinae"
          "toggle"
        ];
        hotkey-overlay.title = "Run an Application: vicinae";
      };
      "Mod+E" = {
        action.spawn = [
          "nautilus"
          "--new-window"
        ];
        hotkey-overlay.title = "Open File Manager: nautilus";
      };
      "Mod+L" = {
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "lockScreen"
          "lock"
        ];
        hotkey-overlay.title = "Lock the Screen: noctalia";
      };
      "Mod+V" = {
        action.spawn = [
          "vicinae"
          "vicinae://extensions/vicinae/clipboard/history"
        ];
        hotkey-overlay.title = "Clipboard History";
      };

      "XF86AudioRaiseVolume" = {
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "volume"
          "increase"
        ];
      };
      "XF86AudioLowerVolume" = {
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "volume"
          "decrease"
        ];
      };
      "XF86AudioMute" = {
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "volume"
          "muteOutput"
        ];
      };
      "XF86AudioMicMute" = {
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "volume"
          "muteInput"
        ];
      };

      "XF86MonBrightnessUp" = {
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "brightness"
          "increase"
        ];
      };
      "XF86MonBrightnessDown" = {
        action.spawn = [
          "noctalia-shell"
          "ipc"
          "call"
          "brightness"
          "decrease"
        ];
      };
    };
  };
}
