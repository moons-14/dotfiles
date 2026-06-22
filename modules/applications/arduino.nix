{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.arduino;
  arduinoIdeX11 = pkgs.arduino-ide.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];

    postFixup = (old.postFixup or "") + ''
      wrapProgram $out/bin/arduino-ide \
        --add-flags "--ozone-platform=x11"
    '';
  });
in
{
  options.my.applications.arduino = {
    enable = lib.mkEnableOption "Arduino development tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      arduino-cli # Arduino command-line interface
      arduinoIdeX11 # Arduino IDE with X11 support
    ];
  };
}
