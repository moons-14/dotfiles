{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.niri.homeManager;
  defaultKeyBind = import ./defaultKeyBind.nix;
in
{
  options.my.applications.niri.homeManager = {
    enable = lib.mkEnableOption "niri home-manager configuration";
  };

  config.home-manager.sharedModules = [
    inputs.niri-flake.homeModules.niri
    {
      config = lib.mkIf cfg.enable {
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

          input.keyboard.xkb = {
            layout = "jp";
            options = "ctrl:nocaps";
          };

          input.mouse = {
            accel-profile = "flat";
            accel-speed = -0.1;
          };

          input.warp-mouse-to-focus.enable = true;
          input.focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "0%";
          };

          spawn-at-startup = [
            { command = [ "noctalia" ]; }
            {
              command = [
                "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
              ];
            }
          ];

          cursor.size = 16;

          outputs = {
            # x1g13 monitor
            "eDP-1" = {
              scale = 1.0;
              position = {
                x = 2240;
                y = 1440;
              };
            };

            # LG WQHD monitor
            "HDMI-A-1" = {
              scale = 1.0;
              position = {
                x = 2560;
                y = 0;
              };
            };

            # DELL monitor
            "DP-3" = {
              scale = 1.5;
              position = {
                x = 0;
                y = 0;
              };
            };
          };

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
            background-color = "transparent";
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
            "Mod+E" = {
              action.spawn = [
                "nautilus"
                "--new-window"
              ];
              hotkey-overlay.title = "Open File Manager: nautilus";
            };
            "Mod+L" = {
              action.spawn = [
                "noctalia"
                "msg"
                "session"
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

            # Focus monitor
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

            # Move focused window to monitor
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

            "XF86AudioRaiseVolume" = {
              action.spawn = [
                "noctalia"
                "msg"
                "volume-up"
              ];
            };
            "XF86AudioLowerVolume" = {
              action.spawn = [
                "noctalia"
                "msg"
                "volume-down"
              ];
            };
            "XF86AudioMute" = {
              action.spawn = [
                "noctalia"
                "msg"
                "volume-mute"
              ];
            };
            "XF86AudioMicMute" = {
              action.spawn = [
                "noctalia"
                "msg"
                "mic-mute"
              ];
            };

            "XF86MonBrightnessUp" = {
              action.spawn = [
                "noctalia"
                "msg"
                "brightness-up"
              ];
            };
            "XF86MonBrightnessDown" = {
              action.spawn = [
                "noctalia"
                "msg"
                "brightness-down"
              ];
            };

            "XF86Favorites" = {
              action.spawn = [
                "noctalia"
                "msg"
                "caffeine-toggle"
              ];
            };
          };

          window-rules = [
            {
              geometry-corner-radius = {
                top-left = 20.0;
                top-right = 20.0;
                bottom-left = 20.0;
                bottom-right = 20.0;
              };
              clip-to-geometry = true;
            }
            {
              matches = [ { app-id = "^dev\\.noctalia\\.Noctalia$"; } ];
              open-floating = true;
              default-column-width = {
                fixed = 1080;
              };
              default-window-height = {
                fixed = 920;
              };
            }
          ];

          layer-rules = [
            {
              matches = [ { namespace = "^noctalia-wallpaper"; } ];
              place-within-backdrop = true;
            }
          ];

          overview = {
            workspace-shadow = {
              enable = false;
            };
          };
        };
      };
    }
  ];
}
