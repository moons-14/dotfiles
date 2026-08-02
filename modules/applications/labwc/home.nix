{ lib, pkgs, ... }:
let
  action = key: name: {
    "@key" = key;
    action = {
      "@name" = name;
    };
  };

  execute = key: command: {
    "@key" = key;
    action = {
      "@name" = "Execute";
      "@command" = command;
    };
  };

  desktopKeybinds = lib.concatMap (
    desktop:
    let
      number = toString desktop;
    in
    [
      {
        "@key" = "W-${number}";
        action = {
          "@name" = "GoToDesktop";
          "@to" = number;
        };
      }
      {
        "@key" = "W-C-${number}";
        action = {
          "@name" = "SendToDesktop";
          "@to" = number;
        };
      }
    ]
  ) (lib.range 1 9);
in
{
  wayland.windowManager.labwc = {
    enable = true;
    # NixOS owns the package so Home Manager only generates the user config.
    package = null;

    rc = {
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
        "@number" = 9;
        "@popupTime" = 500;
        "@prefix" = "Workspace";
      };

      keyboard = {
        default = true;
        numlock = "on";
        keybind = [
          (action "W-q" "Close")
          (action "W-f" "ToggleMaximize")
          (action "W-Tab" "NextWindow")
          (action "W-S-Tab" "PreviousWindow")
          (action "W-j" "NextWindow")
          (action "W-k" "PreviousWindow")
          {
            "@key" = "W-a";
            action = {
              "@name" = "ShowMenu";
              "@menu" = "client-list-combined-menu";
            };
            position = {
              x = "center";
              y = "center";
            };
          }
          (execute "W-t" "ghostty")
          (execute "W-d" "vicinae toggle")
          (execute "W-e" "nautilus --new-window")
          (execute "W-l" "loginctl lock-session")
          (execute "W-v" "vicinae vicinae://launch/clipboard/history?toggle=true")
          (execute "W-space" "ghostty +toggle-quick-terminal")
          (execute "W-p" "wdisplays")
          (execute "W-s" "noctalia msg panel-toggle launcher")
          (execute "W-comma" "noctalia msg settings-toggle")
          (action "W-S-e" "Exit")
        ]
        ++ desktopKeybinds
        ++ [
          (execute "XF86AudioRaiseVolume" "noctalia msg volume-up")
          (execute "XF86AudioLowerVolume" "noctalia msg volume-down")
          (execute "XF86AudioMute" "noctalia msg volume-mute")
          (execute "XF86AudioMicMute" "noctalia msg mic-mute")
          (execute "XF86MonBrightnessUp" "noctalia msg brightness-up")
          (execute "XF86MonBrightnessDown" "noctalia msg brightness-down")
        ];
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

    # Pull in graphical-session.target so Home Manager services such as
    # portals, Vicinae, and the idle manager follow the labwc session.
    systemd.extraCommands = [
      # The wlroots portal is conditionally started with WAYLAND_DISPLAY. It
      # can otherwise be skipped before labwc imports its session environment,
      # leaving the desktop portal without the ScreenCast interface.
      "${lib.getExe' pkgs.systemd "systemctl"} --user restart xdg-desktop-portal-wlr.service"
      "${lib.getExe' pkgs.systemd "systemctl"} --user restart xdg-desktop-portal.service"

      # Clear the previous session's target first. Otherwise services such as
      # kanshi that lose their Wayland connection on logout remain in a
      # failed/start-limit-hit state and are not started for the next login.
      "${lib.getExe' pkgs.systemd "systemctl"} --user stop labwc-session.target"
      "${lib.getExe' pkgs.systemd "systemctl"} --user --no-block start labwc-session.target"
    ];
  };
}
