{ lib, pkgs, ... }:
let
  systemctl = lib.getExe' pkgs.systemd "systemctl";

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
in
{
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
          (action "W-q" "Close")
          (action "W-f" "ToggleMaximize")
          (action "W-c" "Iconify")
          (action "W-Tab" "NextWindow")
          (action "W-S-Tab" "PreviousWindow")
          (action "W-Up" "Lower")
          (action "W-Down" "Raise")
          (action "W-Left" "NextWindow")
          (action "W-Right" "PreviousWindow")
          {
            "@key" = "W-C-Left";
            action = {
              "@name" = "SnapToEdge";
              "@direction" = "left";
              "@combine" = "yes";
            };
          }
          {
            "@key" = "W-C-Right";
            action = {
              "@name" = "SnapToEdge";
              "@direction" = "right";
              "@combine" = "yes";
            };
          }
          {
            "@key" = "W-C-Up";
            action = {
              "@name" = "SnapToEdge";
              "@direction" = "up";
              "@combine" = "yes";
            };
          }
          {
            "@key" = "W-C-Down";
            action = {
              "@name" = "SnapToEdge";
              "@direction" = "down";
              "@combine" = "yes";
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
        ++ [
          (execute "XF86AudioRaiseVolume" "noctalia msg volume-up")
          (execute "XF86AudioLowerVolume" "noctalia msg volume-down")
          (execute "XF86AudioMute" "noctalia msg volume-mute")
          (execute "XF86AudioMicMute" "noctalia msg mic-mute")
          (execute "XF86MonBrightnessUp" "noctalia msg brightness-up")
          (execute "XF86MonBrightnessDown" "noctalia msg brightness-down")
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
