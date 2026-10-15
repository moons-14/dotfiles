{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  wine = pkgs.wineWow64Packages.stable;

  prefix = "${config.home.homeDirectory}/.local/share/wineprefixes/ltspice";
in
lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
  home.packages = [
    wine
  ];

  home.activation.ltspiceWineConfig = inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "${prefix}/system.reg" ]; then
      export WINEPREFIX="${prefix}"

      run ${wine}/bin/wine reg add \
        'HKLM\Software\Microsoft\Windows NT\CurrentVersion\FontSubstitutes' \
        /v 'Tahoma' \
        /t REG_SZ \
        /d 'Noto Sans CJK JP' /f

      run ${wine}/bin/wine reg add \
        'HKLM\Software\Microsoft\Windows NT\CurrentVersion\FontSubstitutes' \
        /v 'MS UI Gothic' \
        /t REG_SZ \
        /d 'Noto Sans CJK JP' /f

      run ${wine}/bin/wine reg add \
        'HKCU\Software\Wine\Fonts' \
        /v LogPixels \
        /t REG_DWORD \
        /d 168 /f
    fi
  '';
}
