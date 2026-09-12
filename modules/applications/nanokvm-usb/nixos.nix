{ pkgs, ... }:
let
  nanokvm-usb = pkgs.appimageTools.wrapType2 rec {
    pname = "nanokvm-usb";
    version = "1.1.4";

    src = pkgs.fetchurl {
      url = "https://github.com/sipeed/NanoKVM-USB/releases/download/v${version}/NanoKVM-USB-${version}-linux-x86_64.AppImage";
      hash = "sha256-00MT4U2afv0qt3xFVhLr0SSmS2cLrKBlmfzqYEFuaVc=";
    };

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
