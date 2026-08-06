{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  codexbar = import ./codexbar.nix { inherit lib pkgs; };
  codexbarUsagePlugin = pkgs.runCommand "noctalia-codexbar-usage-plugin" { } ''
    mkdir -p "$out"
    cp ${./plugins/codexbar-usage/plugin.toml} "$out/plugin.toml"
    substitute ${./plugins/codexbar-usage/usage.luau} "$out/usage.luau" \
      --replace-fail "@codexbarPath@" "${lib.getExe codexbar}"
  '';

  noctaliaPatched =
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
      (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [
          ./patches/window-switcher-labwc.patch
          ./patches/taskbar-overview-hook.patch
        ];
      });

  wallpapers = pkgs.fetchFromGitHub {
    owner = "moons-14";
    repo = "wallpapers";
    rev = "cc3256f4aaf2c8e7d16fb000b1ee251af54085db";
    hash = "sha256-emQ/FqKqMq3YI5bLx8gBZg/ZE72OG9Ilh71ggq78WdQ=";
  };
in
{
  home.packages = [
    codexbar
    pkgs.networkmanagerapplet
  ];

  home.file = {
    ".face".source = ../../../images/avatar.jpg;
    ".wallpapers" = {
      source = wallpapers;
      recursive = true;
    };
  };

  xdg.dataFile."noctalia/plugins/codexbar-usage" = {
    source = codexbarUsagePlugin;
    recursive = true;
  };

  programs.noctalia = {
    enable = true;

    package = noctaliaPatched;

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
        enabled = true;
        fingerprint = true;
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
          "spacer"
          "taskbar"
        ];
        center = [
          "app-launcher"
          "workspaces"
        ];
        end = [
          "moons/codexbar-usage:usage"
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

      plugins = {
        enabled = [ "moons/codexbar-usage" ];
      };

      widget = {
        app-launcher = {
          type = "custom_button";
          glyph = "apps";
          actions.left = "vicinae toggle";
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
          show_label = false;
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
          actions.left = "nm-connection-editor";
        };
        tray = {
          type = "tray";
          pinned = [ "org.fcitx.Fcitx5" ];
        };
        workspaces = {
          type = "workspaces";
          hide_when_empty = true;
        };
        taskbar = {
          type = "taskbar";
          scale = 1;
          pinned = [
            "org.gnome.Nautilus"
            "org.gnome.TextEditor"
            "com.mitchellh.ghostty"
            "thunderbird"
            "google-chrome"
            "code"
            "dev.zed.Zed"
            "codex-desktop"
            "vesktop"
          ];
          show_all_outputs = true;
          group_by_workspace = false;
          show_window_title = false;
          pinned_opacity = 0.60;
          inactive_opacity = 1.0;
        };
      };

      shell = {
        avatar_path = "~/.face";
        corner_radius_scale = 0.2;
        clipboard_enabled = false;
        launch_apps_as_systemd_services = true;

        session = {
          grid = true;
          grid_columns = 3;

          actions = [
            {
              action = "lock";
            }
            {
              action = "logout";
            }
            {
              action = "lock_and_suspend";
            }
            {
              action = "command";
              label = "Display OFF";

              command = "${pkgs.dpms-off}/bin/dpms-off";

              variant = "secondary";
            }
            {
              action = "reboot";
              variant = "destructive";
              countdown_seconds = 5;
            }
            {
              action = "shutdown";
              variant = "destructive";
              countdown_seconds = 5;
            }
          ];
        };
      };

      wallpaper = {
        enabled = lib.mkDefault true;
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
        enabled = false;
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
