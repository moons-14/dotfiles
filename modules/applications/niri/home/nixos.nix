{ lib, pkgs, ... }:
let
  keybindings = import ./keybindings.nix;
in
{
  programs.niri.settings = {

    binds = keybindings // {
      # niri window or focus move
      "Mod+Shift+Left" = {
        action.focus-monitor-left = [ ];
        hotkey-overlay.title = "Focus Monitor Left";
      };
      "Mod+Shift+Right" = {
        action.focus-monitor-right = [ ];
        hotkey-overlay.title = "Focus Monitor Right";
      };
      "Mod+Shift+Up" = {
        action.focus-monitor-up = [ ];
        hotkey-overlay.title = "Focus Monitor Up";
      };
      "Mod+Shift+Down" = {
        action.focus-monitor-down = [ ];
        hotkey-overlay.title = "Focus Monitor Down";
      };

      # Use the modifier combinations in the opposite direction from Niri's defaults.
      "Mod+WheelScrollDown".action.focus-column-right = [ ];
      "Mod+WheelScrollUp".action.focus-column-left = [ ];
      "Mod+Shift+WheelScrollDown" = {
        cooldown-ms = 150;
        action.focus-workspace-down = [ ];
      };
      "Mod+Shift+WheelScrollUp" = {
        cooldown-ms = 150;
        action.focus-workspace-up = [ ];
      };

      "Mod+Shift+Ctrl+Left" = {
        action.move-window-to-monitor-left = [ ];
        hotkey-overlay.title = "Move Window to Monitor Left";
      };
      "Mod+Shift+Ctrl+Right" = {
        action.move-window-to-monitor-right = [ ];
        hotkey-overlay.title = "Move Window to Monitor Right";
      };
      "Mod+Shift+Ctrl+Up" = {
        action.move-window-to-monitor-up = [ ];
        hotkey-overlay.title = "Move Window to Monitor Up";
      };
      "Mod+Shift+Ctrl+Down" = {
        action.move-window-to-monitor-down = [ ];
        hotkey-overlay.title = "Move Window to Monitor Down";
      };

      "Mod+Tab" = {
        repeat = false;
        action.spawn = [
          "window-overview"
          "--hold"
        ];
        hotkey-overlay.title = "Window Overview: Next";
      };
      "Mod+Shift+Tab" = {
        repeat = false;
        action.spawn = [
          "window-overview"
          "--hold"
          "--reverse"
        ];
        hotkey-overlay.title = "Window Overview: Previous";
      };

      "Print".action.spawn = [
        "screenshot"
        "region"
      ];
      "Ctrl+Print".action.spawn = [
        "screenshot"
        "output"
      ];
      "Alt+Print".action.spawn = [
        "screenshot"
        "all"
      ];

      # spawn applications (sync with labwc modules/applications/labwc/home.nix)
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
      "Mod+S" = {
        action.spawn = [
          "noctalia"
          "msg"
          "panel-toggle"
          "launcher"
        ];
        hotkey-overlay.title = "Run an Application: Noctalia Launcher";
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
          (lib.getExe' pkgs.systemd "loginctl")
          "lock-session"
        ];
        hotkey-overlay.title = "Lock the Screen";
      };
      "Mod+V" = {
        action.spawn = [
          "vicinae"
          "vicinae://launch/clipboard/history"
        ];
        hotkey-overlay.title = "Clipboard History";
      };
      "Mod+J" = {
        repeat = false;
        action.spawn = [ "nani-translate-primary" ];
        hotkey-overlay.title = "Translate Primary Selection";
      };
      "Mod+Shift+J" = {
        repeat = false;
        action.spawn = [ "nani-translate-ocr" ];
        hotkey-overlay.title = "OCR and Translate with Nani";
      };
      "Mod+Ctrl+J" = {
        repeat = false;
        action.spawn = [
          (lib.getExe' pkgs.xdg-utils "xdg-open")
          "naniapp://translate"
        ];
        hotkey-overlay.title = "Open Nani Translate";
      };
      "Mod+Space" = {
        action.spawn = [
          "ghostty"
          "+toggle-quick-terminal"
        ];
        hotkey-overlay.title = "Toggle Quick Terminal: ghostty";
      };
      "Mod+P" = {
        action.spawn = "wdisplays";
        hotkey-overlay.title = "Display Settings: wdisplays";
      };
      "Mod+Z" = {
        action.spawn = [
          "wl-find-cursor"
          "-c"
          "0xCCFF453A"
          "-s"
          "160"
          "-d"
          "1200"
        ];
        hotkey-overlay.title = "Find Cursor";
      };
      "Ctrl+Space" = {
        action.spawn = [
          "handy"
          "--toggle-transcription"
        ];
        hotkey-overlay.title = "Toggle Handy Transcription";
      };

      # Function keys (sync with labwc modules/applications/labwc/home.nix)
      "XF86AudioRaiseVolume".action.spawn = [
        "noctalia"
        "msg"
        "volume-up"
      ];
      "XF86AudioLowerVolume".action.spawn = [
        "noctalia"
        "msg"
        "volume-down"
      ];
      "XF86AudioMute".action.spawn = [
        "noctalia"
        "msg"
        "volume-mute"
      ];
      "XF86AudioMicMute".action.spawn = [
        "noctalia"
        "msg"
        "mic-mute"
      ];
      "XF86MonBrightnessUp".action.spawn = [
        "noctalia"
        "msg"
        "brightness-up"
      ];
      "XF86MonBrightnessDown".action.spawn = [
        "noctalia"
        "msg"
        "brightness-down"
      ];
      "XF86Favorites".action.spawn = [
        "noctalia"
        "msg"
        "caffeine-toggle"
      ];
      "XF86AudioPlay".action.spawn = [
        "playerctl"
        "play-pause"
      ];
      "XF86AudioPause".action.spawn = [
        "playerctl"
        "play-pause"
      ];
      "XF86AudioStop".action.spawn = [
        "playerctl"
        "stop"
      ];
      "XF86AudioPrev".action.spawn = [
        "playerctl"
        "previous"
      ];
      "XF86AudioNext".action.spawn = [
        "playerctl"
        "next"
      ];
      "XF86Display".action.spawn = [
        "wdisplays"
      ];
    };

    input = {
      touchpad = {
        natural-scroll = true;
        scroll-factor = 4.0;
        scroll-method = "two-finger";
        click-method = "clickfinger";
        drag = true;
        drag-lock = true;
        dwt = true;
      };

      keyboard = {
        numlock = true;

        xkb = {
          layout = "jp";
          options = "ctrl:nocaps";
        };
      };

      mouse = {
        accel-profile = "flat";
        accel-speed = -0.1;
      };
      trackpoint = {
        accel-profile = "flat";
        accel-speed = -0.1;
      };

      warp-mouse-to-focus.enable = true;
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };
    };

    cursor.size = 16;

    layout = {
      focus-ring = {
        active.color = "#bd93f9";
        inactive.color = "#6272a4";
      };
      background-color = "transparent";
    };

    window-rules = [
      {
        geometry-corner-radius = {
          top-left = 8.0;
          top-right = 8.0;
          bottom-left = 8.0;
          bottom-right = 8.0;
        };
        clip-to-geometry = true;
      }
      {
        matches = [ { app-id = "^dev\\.noctalia\\.Noctalia$"; } ];
        open-floating = true;
        default-column-width.fixed = 1080;
        default-window-height.fixed = 920;
      }
      {
        # Zoom presents these two fixed-size primary windows. Explicitly keep
        # them tiled, overriding Niri's automatic fixed-size-window floating.
        matches = [
          {
            app-id = "^(?i:zoom)$";
            title = "^(?i:zoom workplace)$";
          }
          {
            app-id = "^(?i:zoom)$";
            title = "^ミーティング$";
          }
        ];
        open-floating = false;
      }
      {
        # Zoom's screen-share controls are a toolbar, so open them where the
        # client expects them rather than in the middle of the workspace.
        matches = [
          {
            app-id = "^(?i:zoom)$";
            title = "^as_toolbar$";
          }
        ];
        open-floating = true;
        default-floating-position = {
          x = 0;
          y = 8;
          relative-to = "top";
        };
      }
      {
        # Keep all other Zoom auxiliary windows freely positionable.
        matches = [ { app-id = "^(?i:zoom)$"; } ];
        excludes = [
          { title = "^(?i:zoom workplace)$"; }
          { title = "^ミーティング$"; }
        ];
        open-floating = true;
      }
    ];

    layer-rules = [
      {
        matches = [ { namespace = "^noctalia-wallpaper"; } ];
        place-within-backdrop = true;
      }
    ];

    overview.workspace-shadow.enable = false;
  };
}
