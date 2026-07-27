{ pkgs, ... }:
let
  arduinoIdeX11 = pkgs.arduino-ide.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];

    postFixup = (old.postFixup or "") + ''
      wrapProgram $out/bin/arduino-ide \
        --add-flags "--ozone-platform=x11"
    '';
  });
in
{
  environment.systemPackages = [ arduinoIdeX11 ];
}
