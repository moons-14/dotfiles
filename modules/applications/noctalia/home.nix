{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.noctalia.homeManager;
  walls = pkgs.fetchFromGitHub {
    owner = "moons-14";
    repo = "wallpapers";
    rev = "cc3256f4aaf2c8e7d16fb000b1ee251af54085db";
    hash = "sha256-emQ/FqKqMq3YI5bLx8gBZg/ZE72OG9Ilh71ggq78WdQ=";
  };
in
{
  options.my.applications.noctalia.homeManager = {
    enable = lib.mkEnableOption "noctalia home-manager configuration";
  };

  config.home-manager.sharedModules = [
    inputs.noctalia.homeModules.default
    {
      config = lib.mkIf cfg.enable {
        home.file.".face" = {
          recursive = true;
          source = ../../../images/avatar.jpg;
        };

        home.file.".wallpapers" = {
          source = walls;
          recursive = true;
        };

        home.file.".cache/noctalia/wallpapers.json" = {
          text = builtins.toJSON {
            defaultWallpaper = "~/.wallpapers/1.jpg";
            wallpapers = {
              "DP-1" = "~/.wallpapers/1.jpg";
            };
          };
        };

        programs.noctalia = {
          enable = true;
          settings = {
            theme = {
              mode = "auto";
              source = "wallpaper";
              templates = {
                enable_builtin_templates = false;
                enable_community_templates = false;
              };
            };
            desktop_widgets.enabled = false;
            lockscreen = {
              enabled = false;
              fingerprint = false;
            };
            widget = {
              cpu = {
                type = "sysmon";
                stat = "cpu_usage";
              };
              cpu-graph = {
                type = "sysmon";
                stat = "cpu_usage";
                display = "graph";
                show_label = false;
              };
              ram = {
                type = "sysmon";
                stat = "ram_used";
              };
              media = {
                type = "media";
                hide_when_no_media = true;
                title_scroll = "always";
              };
              battery = {
                type = "battery";
                display_mode = "graphic";
                warning_threshold = 30;
              };
              brightness = {
                type = "brightness";
                show_label = false;
              };
              input-volume = {
                type = "volume";
                device = "input";
              };
              output-volume = {
                type = "volume";
                device = "output";
              };
              clock = {
                type = "clock";
                format = "{:%Y/%m/%d %H:%M}";
                vertical_format = "{:%Y/%m/%d\n%H:%M}";
                tooltip_format = "{:%Y/%m/%d %H:%M (%a)}";
              };
              network-connection = {
                type = "custom_button";
                glyph = "access-point";
                command = "nm-connection-editor";
              };
              tray = {
                type = "tray";
                pinned = [ "org.fcitx.Fcitx5" ];
              };
            };

            bar = {
              order = [ "main" ];
              main = {
                margin_ends = 15;
                position = "top";
                start = [
                  "network"
                  "bluetooth"
                  "network-connection"
                  "spacer"
                  "cpu"
                  "cpu-graph"
                  "ram"
                ];
                center = [ "workspaces" ];
                end = [
                  "media"
                  "spacer"
                  "notifications"
                  "tray"
                  "spacer"
                  "battery"
                  "input-volume"
                  "output-volume"
                  "privacy"
                  "brightness"
                  "clock"
                  "control-center"
                ];
              };
            };
            colorSchemes.predefinedScheme = "dracula";
            general = {
              avatarImage = "~/.face";
              radiusRatio = 0.2;
            };
            location = {
              monthBeforeDay = true;
              weatherEnabled = false;
              name = "Tokyo";
            };
            wallpaper = {
              enabled = true;
              directory = "~/.wallpapers/";
              fillMode = "crop";
              automation = {
                enabled = true;
                order = "random";
                interval_seconds = 60;
              };
              default.path = "~/.wallpapers/1.jpg";
            };
            dock = {
              enabled = true;
              position = "left";
              auto_hide = true;
              show_dots = true;
              background_opacity = 0.8;
              size = 1;
              onlySameOutput = true;
              reserve_space = false;
              monitors = [ "eDP-1" ];
              pinned = [
                "com.mitchellh.ghostty"
                "google-chrome"
                "code"
              ];
              colorizeIcons = false;
            };
            shell = {
              clipboard_enabled = false;
            };
            controlCenter = {
              position = "close_to_bar_button";
              shortcuts = {
                left = [
                  { id = "WiFi"; }
                  { id = "Bluetooth"; }
                  { id = "ScreenRecorder"; }
                  { id = "WallpaperSelector"; }
                ];
                right = [
                  { id = "Notifications"; }
                  { id = "NightLight"; }
                ];
              };
              cards = [
                {
                  enabled = true;
                  id = "profile-card";
                }
                {
                  enabled = true;
                  id = "shortcuts-card";
                }
                {
                  enabled = true;
                  id = "audio-card";
                }
                {
                  enabled = true;
                  id = "media-sysmon-card";
                }
              ];
            };
          };
        };
      };
    }
  ];
}
