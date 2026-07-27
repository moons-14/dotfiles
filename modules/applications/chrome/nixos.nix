{ pkgs, ... }:
let
  chromeLauncher = pkgs.makeDesktopItem {
    name = "google-chrome";
    desktopName = "Google Chrome";
    genericName = "Web Browser";
    exec = "${pkgs.google-chrome}/bin/google-chrome-stable --enable-features=TouchpadOverscrollHistoryNavigation %U";
    icon = "google-chrome";
    terminal = false;
    categories = [
      "Network"
      "WebBrowser"
    ];
    startupNotify = true;
  };
in
{
  environment.systemPackages = [ chromeLauncher ];

  xdg.mime.defaultApplications = {
    "text/html" = "google-chrome.desktop";
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
  };
}
