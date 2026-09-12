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

    meta = {
      description = "Sipeed NanoKVM-USB desktop client";
      homepage = "https://github.com/sipeed/NanoKVM-USB";
      license = pkgs.lib.licenses.gpl3Only;
      platforms = [ "x86_64-linux" ];
      mainProgram = "nanokvm-usb";
    };
  };

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "NanoKVM-USB";
    comment = "NanoKVM-USB Desktop";
    exec = "nanokvm-usb --no-sandbox %U";
    icon = "${appimageContents}/nanokvm-usb.png";
    categories = [ "Utility" ];
    startupWMClass = "NanoKVM-USB";
  };
in
{
  environment.systemPackages = [
    nanokvm-usb
    desktopItem
  ];
}
