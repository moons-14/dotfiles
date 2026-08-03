_: {
  programs.google-chrome = {
    enable = true;

    commandLineArgs = [
      "--enable-features=MiddleClickAutoscroll"
    ];
  };

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "text/html" = "google-chrome.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
    };
  };
}
