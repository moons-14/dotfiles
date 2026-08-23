_: {
  programs.google-chrome = {
    enable = true;

    commandLineArgs = [
      "--enable-features=MiddleClickAutoscroll,AcceleratedVideoDecoder,AcceleratedVideoDecodeLinuxGL,VaapiOnNvidiaGPUs,PlatformHEVCDecoderSupport"
      "--use-gl=angle"
      "--use-angle=gl"
    ];
  };

  home.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
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
