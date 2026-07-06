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
            bar = {
              density = "default";
              position = "top";
              showCapsule = true;
              backgroundOpacity = 0.8;
              floating = true;
              widgets = {
                left = [
                  { id = "WiFi"; }
                  {
                    id = "CustomButton";
                    icon = "access-point";
                    leftClickExec = "nm-connection-editor";
                  }
                  { id = "Bluetooth"; }
                  { id = "SystemMonitor"; }
                  { id = "Taskbar"; }
                  { id = "ActiveWindow"; }
                ];
                center = [
                  {
                    hideUnoccupied = false;
                    id = "Workspace";
                    labelMode = "none";
                  }
                ];
                right = [
                  { id = "MediaMini"; }
                  { id = "NotificationHistory"; }
                  {
                    displayMode = "alwaysShow";
                    id = "Battery";
                    warningThreshold = 30;
                  }
                  {
                    displayMode = "alwaysShow";
                    id = "Volume";
                  }
                  {
                    displayMode = "alwaysShow";
                    id = "Brightness";
                  }
                  {
                    formatHorizontal = "HH:mm";
                    formatVertical = "HH mm";
                    id = "Clock";
                    useMonospacedFont = true;
                    usePrimaryColor = true;
                  }
                  {
                    id = "ControlCenter";
                    useDistroLogo = true;
                  }
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
              setWallpaperOnAllMonitors = true;
              linkLightAndDarkWallpapers = true;
              fillMode = "crop";
              randomEnabled = true;
              randomIntervalSec = 60;
              transitionDuration = 1500;
            };
            dock = {
              enabled = true;
              displayMode = "auto_hide";
              backgroundOpacity = 0.8;
              floatingRatio = 1;
              size = 1;
              onlySameOutput = true;
              monitors = [ "eDP-1" ];
              pinnedApps = [
                "com.mitchellh.ghostty"
                "org.gnome.Nautilus"
                "google-chrome"
                "code"
              ];
              colorizeIcons = false;
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
