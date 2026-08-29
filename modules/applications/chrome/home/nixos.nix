{
  config,
  lib,
  pkgs,
  ...
}:
let
  chrome = pkgs.google-chrome.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];

    postFixup = (old.postFixup or "") + ''
      wrapProgram $out/bin/google-chrome-stable \
        --set LIBVA_DRIVER_NAME nvidia \
        --set NVD_BACKEND direct
    '';
  });

  features = [
    "MiddleClickAutoscroll"
    "AcceleratedVideoDecoder"
    "AcceleratedVideoDecodeLinuxGL"
    "PlatformHEVCDecoderSupport"
  ]
  ++ lib.optional config.my.hardwares.nvidia.enable "VaapiOnNvidiaGPUs";
in
{
  programs.google-chrome = {
    enable = true;
    package = if config.my.hardwares.nvidia.enable then chrome else pkgs.google-chrome;

    commandLineArgs = [
      "--enable-features=${lib.concatStringsSep "," features}"
      "--use-gl=angle"
      "--use-angle=gl"
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
