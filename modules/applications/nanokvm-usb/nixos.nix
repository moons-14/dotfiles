{ pkgs, ... }:
let
  pname = "nanokvm-usb";
  version = "1.1.4";

  src = pkgs.fetchurl {
    url = "https://github.com/sipeed/NanoKVM-USB/releases/download/v${version}/NanoKVM-USB-${version}-linux-x86_64.AppImage";
    hash = "sha256-00MT4U2afv0qt3xFVhLr0SSmS2cLrKBlmfzqYEFuaVc=";
  };

  appimageContents = pkgs.appimageTools.extractType2 {
    inherit pname src version;
  };

  nanokvm-usb = pkgs.appimageTools.wrapType2 {
    inherit pname src version;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/nanokvm-usb.desktop \
        $out/share/applications/nanokvm-usb.desktop
      install -m 444 -D ${appimageContents}/nanokvm-usb.png \
        $out/share/icons/hicolor/512x512/apps/nanokvm-usb.png
      substituteInPlace $out/share/applications/nanokvm-usb.desktop \
        --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=nanokvm-usb --no-sandbox %U'
    '';

    meta = {
      description = "Sipeed NanoKVM-USB desktop client";
      homepage = "https://github.com/sipeed/NanoKVM-USB";
      license = pkgs.lib.licenses.gpl3Only;
      platforms = [ "x86_64-linux" ];
      mainProgram = "nanokvm-usb";
    };
  };
in
{
  environment.systemPackages = [ nanokvm-usb ];
}
