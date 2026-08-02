{ pkgs, ... }:
{
  home.packages = [ pkgs.google-chrome ];

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "text/html" = "google-chrome.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
    };
  };
}
