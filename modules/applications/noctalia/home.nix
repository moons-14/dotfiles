{ pkgs, ... }:
let
  wallpapers = pkgs.fetchFromGitHub {
    owner = "moons-14";
    repo = "wallpapers";
    rev = "cc3256f4aaf2c8e7d16fb000b1ee251af54085db";
    hash = "sha256-emQ/FqKqMq3YI5bLx8gBZg/ZE72OG9Ilh71ggq78WdQ=";
  };
in
{
  home.packages = [ pkgs.networkmanagerapplet ];

  home.file = {
    ".face".source = ../../../images/avatar.jpg;
    ".wallpapers" = {
      source = wallpapers;
      recursive = true;
    };
  };

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

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

      bar.main = {
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

      shell = {
        avatar_path = "~/.face";
        corner_radius_scale = 0.2;
        clipboard_enabled = false;
        launch_apps_as_systemd_services = true;
      };

      wallpaper = {
        enabled = true;
        directory = "~/.wallpapers";
        fill_mode = "crop";
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
        active_monitor_only = true;
        reserve_space = false;
        pinned = [
          "com.mitchellh.ghostty"
          "google-chrome"
          "code"
        ];
      };

      control_center.shortcuts = [
        { type = "wifi"; }
        { type = "bluetooth"; }
        { type = "screen_recorder"; }
        { type = "wallpaper"; }
        { type = "notifications"; }
        { type = "nightlight"; }
      ];
    };
  };
}
