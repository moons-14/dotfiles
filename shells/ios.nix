_: {
  perSystem =
    { pkgs, ... }:
    let
      installIosSimulator = pkgs.writeShellApplication {
        name = "ios-simulator-install";
        text = ''
          if [[ "$(/usr/bin/uname -s)" != "Darwin" ]]; then
            echo "ios-simulator-install is only supported on macOS." >&2
            exit 1
          fi

          xcode_app="/Applications/Xcode.app"
          developer_dir="$xcode_app/Contents/Developer"

          if [[ ! -d "$developer_dir" ]]; then
            echo "Xcode is not installed at $xcode_app." >&2
            echo "Apply the m2 nix-darwin configuration first." >&2
            exit 1
          fi

          current_developer_dir="$(/usr/bin/xcode-select -p 2>/dev/null || true)"
          if [[ "$current_developer_dir" != "$developer_dir" ]]; then
            echo "Selecting stable Xcode..."
            /usr/bin/sudo /usr/bin/xcode-select --switch "$developer_dir"
          fi

          echo "Installing Xcode first-launch components..."
          /usr/bin/sudo /usr/bin/xcodebuild -runFirstLaunch

          echo "Checking for newer hardware support..."
          /usr/bin/xcodebuild -runFirstLaunch -checkForNewerComponents

          echo "Downloading and installing the latest iOS Simulator runtime..."
          /usr/bin/xcodebuild -downloadPlatform iOS

          echo
          /usr/bin/xcodebuild -version
          /usr/bin/xcrun simctl list runtimes
        '';
      };
    in
    {
      devShells.ios = pkgs.mkShell {
        packages = [ installIosSimulator ];
      };
    };
}
