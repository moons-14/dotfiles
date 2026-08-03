{ lib, pkgs, ... }:
let
  screenshot = import ./screenshot.nix { inherit pkgs; };

  systemctl = lib.getExe' pkgs.systemd "systemctl";

  keybind = key: actionAttrs: {
    "@key" = key;
    action = actionAttrs;
  };

  action =
    key: name:
    keybind key {
      "@name" = name;
    };

  execute =
    key: command:
    keybind key {
      "@name" = "Execute";
      "@command" = command;
    };

  snapToEdge =
    key: direction:
    keybind key {
      "@name" = "SnapToEdge";
      "@direction" = direction;
      "@combine" = "yes";
    };

  confirmAction = key: message: name: {
    "@key" = key;
    action = {
      "@name" = "If";
      prompt."@message" = message;
      "then".action."@name" = name;
    };
  };
in
{
  home.packages = [ screenshot ];

  wayland.windowManager.labwc = {
    enable = true;
    # NixOS owns the package so Home Manager only generates the user config.
    package = null;

    systemd = {
      enable = true;

      variables = [
        "DISPLAY"
        "WAYLAND_DISPLAY"
        "XDG_CURRENT_DESKTOP"
        "XDG_SESSION_TYPE"
      ];
    };

    rc = {

      keyboard = {
        default = true;
        numlock = "on";
        keybind = [
          # labwc window management
          (action "W-q" "Close")
          (action "W-f" "ToggleMaximize")
          (action "W-c" "Iconify")
          (action "W-Tab" "NextWindow")
          (action "W-S-Tab" "PreviousWindow")
          (action "W-Up" "Lower")
          (action "W-Down" "Raise")
          (action "W-Left" "NextWindow")
          (action "W-Right" "PreviousWindow")
          (snapToEdge "W-C-Left" "left")
          (snapToEdge "W-C-Right" "right")
          (snapToEdge "W-C-Up" "up")
          (snapToEdge "W-C-Down" "down")
          (confirmAction "W-S-e" "Exit labwc?" "Exit")
          (execute "Print" "labwc-screenshot region")
          (execute "C-Print" "labwc-screenshot output")
          (execute "A-Print" "labwc-screenshot all")

          # spawn applications (sync with niri modules/applications/niri/home.nix)
          (execute "W-t" "ghostty")
          (execute "W-d" "vicinae toggle")
          (execute "W-s" "noctalia msg panel-toggle launcher")
          (execute "W-e" "nautilus --new-window")
          (execute "W-l" "loginctl lock-session")
          (execute "W-v" "vicinae vicinae://launch/clipboard/history?toggle=true")
          (execute "W-space" "ghostty +toggle-quick-terminal")
          (execute "W-p" "wdisplays")

          # Function keys (sync with niri modules/applications/niri/home.nix)
          (execute "XF86AudioRaiseVolume" "noctalia msg volume-up")
          (execute "XF86AudioLowerVolume" "noctalia msg volume-down")
          (execute "XF86AudioMute" "noctalia msg volume-mute")
          (execute "XF86AudioMicMute" "noctalia msg mic-mute")
          (execute "XF86MonBrightnessUp" "noctalia msg brightness-up")
          (execute "XF86MonBrightnessDown" "noctalia msg brightness-down")
          (execute "XF86Favorites" "noctalia msg caffeine-toggle")
          (execute "XF86AudioPlay" "playerctl play-pause")
          (execute "XF86AudioPause" "playerctl play-pause")
          (execute "XF86AudioStop" "playerctl stop")
          (execute "XF86AudioPrev" "playerctl previous")
          (execute "XF86AudioNext" "playerctl next")
          (execute "XF86Display" "wdisplays")
        ];
      };

      core = {
        decoration = "client";
        gap = 10;
        autoEnableOutputs = "yes";
        reuseOutputMode = "yes";
      };

      theme = {
        name = "Dracula";
        cornerRadius = 8;
        dropShadows = "yes";
        dropShadowsOnTiled = "yes";
      };

      windowSwitcher = {
        "@preview" = "yes";
        "@outlines" = "yes";
        osd = {
          "@style" = "thumbnail";
        };
      };

      focus = {
        followMouse = "yes";
        followMouseRequiresMovement = "yes";
        raiseOnFocus = "no";
      };

      desktops = {
        "@number" = 1;
        "@popupTime" = 500;
        "@prefix" = "Workspace";
      };

      mouse.default = true;

      libinput.device = [
        {
          "@category" = "touchpad";
          naturalScroll = "yes";
          tap = "yes";
          tapAndDrag = "yes";
          dragLock = "yes";
          clickMethod = "clickfinger";
          scrollMethod = "twoFinger";
          scrollFactor = "4.0";
          disableWhileTyping = "yes";
        }
        {
          "@category" = "non-touch";
          pointerSpeed = "-0.1";
          accelProfile = "flat";
        }
      ];
    };

    environment = [
      "XKB_DEFAULT_LAYOUT=jp"
      "XKB_DEFAULT_OPTIONS=ctrl:nocaps"
    ];
  };

  xdg.configFile."labwc/shutdown".text = lib.mkAfter ''
    ${systemctl} --user stop graphical-session.target
  '';
}
