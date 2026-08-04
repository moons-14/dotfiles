{
  inputs,
  pkgs,
  ...
}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    package = unstable.pipewire;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."90-echo-cancel.conf" = {
      "context.modules" = [
        {
          name = "libpipewire-module-echo-cancel";

          args = {
            "library.name" = "aec/libspa-aec-webrtc";

            "monitor.mode" = true;

            "capture.props" = {
              "node.name" = "echo_cancel_capture";
              "node.description" = "Echo Cancel Capture";
            };

            "source.props" = {
              "node.name" = "echo_cancel_source";
              "node.description" = "Echo Cancelled Microphone";
            };
          };
        }
      ];
    };
  };
}
