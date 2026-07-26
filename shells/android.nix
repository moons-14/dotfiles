_: {
  perSystem =
    { pkgs, ... }:
    {
      devShells.android = pkgs.mkShell {
        packages = with pkgs; [
          android-tools # adb, fastboot
        ];

        shellHook = ''
          alias adb-shutter-off='adb shell settings put system csc_pref_camera_forced_shuttersound_key 0'
        '';
      };
    };
}
