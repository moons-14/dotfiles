{
  config,
  lib,
  pkgs,
  ...
}:
let
  wallpapers = pkgs.fetchFromGitHub {
    owner = "moons-14";
    repo = "wallpapers";
    rev = "cc3256f4aaf2c8e7d16fb000b1ee251af54085db";
    hash = "sha256-emQ/FqKqMq3YI5bLx8gBZg/ZE72OG9Ilh71ggq78WdQ=";
  };

  labwcSettings = lib.recursiveUpdate config.programs.noctalia.settings {
    dock = {
      position = "bottom";
      icon_size = 32;
      main_axis_padding = 10;
      cross_axis_padding = 4;
      item_spacing = 4;
      margin_edge = 0;
      radius = 8;
      background_opacity = 0.9;
      show_running = true;
      auto_hide = false;
      smart_auto_hide = false;
      reserve_space = true;
      active_scale = 1.0;
      inactive_scale = 1.0;
      magnification = false;
      show_instance_count = true;
      active_monitor_only = false;
    };
  };

  labwcRawConfig = (pkgs.formats.toml { }).generate "noctalia-labwc-config.toml" labwcSettings;
  labwcConfig = pkgs.runCommand "noctalia-labwc-config" { } ''
    ${lib.getExe config.programs.noctalia.package} config validate ${labwcRawConfig}
    cp ${labwcRawConfig} $out
  '';

  mkSessionService = target: environment: {
    Unit = {
      Description = "Noctalia Wayland desktop shell";
      Documentation = [ "https://docs.noctalia.dev/" ];
      PartOf = [ target ];
      After = [ target ];
    };

    Service = {
      ExecStart = lib.getExe config.programs.noctalia.package;
      Restart = "on-failure";
    }
    // lib.optionalAttrs (environment != [ ]) {
      Environment = environment;
    };

    Install.WantedBy = [ target ];
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

    # Session-specific services below let labwc select its own config home.
    systemd.enable = false;

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

      osd.kinds = {
        keyboard_layout = false;
        media = false;
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
        center = [
          "app-launcher"
          "workspaces"
        ];
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
        app-launcher = {
          type = "custom_button";
          glyph = "apps";
          command = "vicinae toggle";
          tooltip = "Applications";
        };
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
        workspaces = {
          type = "workspaces";
          hide_when_empty = true;
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

  systemd.user.services =
    lib.optionalAttrs config.my.applications.niri.enable {
      noctalia-niri = mkSessionService "niri.service" [ ];
    }
    // lib.optionalAttrs config.my.applications.labwc.enable {
      noctalia-labwc = mkSessionService "labwc-session.target" [
        "NOCTALIA_CONFIG_HOME=%h/.config/noctalia-labwc"
      ];
    };

  xdg.configFile."noctalia-labwc/noctalia/config.toml".source = labwcConfig;
}
