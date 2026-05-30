{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.chrome;
in
{
  options.my.applications.chrome = {
    enable = lib.mkEnableOption "Google Chrome browser";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          google-chrome # Popular web browser from Google
        ];

        xdg.desktopEntries."google-chrome" = {
          name = "Google Chrome";
          genericName = "Web Browser";
          exec = "${pkgs.google-chrome}/bin/google-chrome-stable --enable-features=TouchpadOverscrollHistoryNavigation %U";
          terminal = false;
          icon = "google-chrome";
          categories = [
            "Network"
            "WebBrowser"
          ];
          startupNotify = true;
          type = "Application";
        };

        xdg.mimeApps.defaultApplications = {
          "text/html" = "google-chrome.desktop";
          "x-scheme-handler/http" = "google-chrome.desktop";
          "x-scheme-handler/https" = "google-chrome.desktop";
        };
      }
    ];
  };
}
