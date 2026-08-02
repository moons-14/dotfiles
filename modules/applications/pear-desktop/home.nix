{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  configDirectory =
    if isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/YouTube Music"
    else
      "${config.xdg.configHome}/YouTube Music";
  configFile = "${configDirectory}/config.json";
  managedConfig = {
    options.autoUpdates = false;
    plugins = {
      performance-improvement.enabled = true;
      synced-lyrics = {
        enabled = true;
        preciseTiming = true;
        showLyricsEvenIfInexact = true;
        showTimeCodes = false;
        defaultTextString = "♪";
        lineEffect = "fancy";
        romanization = true;
      };
      do-not-track = {
        enabled = true;
        cache = true;
      };
      album-color-theme = {
        enabled = true;
        ratio = 0.5;
        enableSeekbar = true;
      };
      custom-output-device.enabled = true;
    };
  };
in
{
  home.packages = lib.optionals isLinux [ unstable.pear-desktop ];

  home.activation.configurePearDesktop = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      config_directory=${lib.escapeShellArg configDirectory}
      config_file=${lib.escapeShellArg configFile}
      managed_config=${lib.escapeShellArg (builtins.toJSON managedConfig)}

      if [ -n "''${DRY_RUN_CMD:-}" ]; then
        echo "Would merge managed Pear Desktop settings into $config_file"
      else
        umask 077
        mkdir -p "$config_directory"

        if [ ! -f "$config_file" ]; then
          printf '{}\n' > "$config_file"
        fi

        if ${pkgs.jq}/bin/jq -e . "$config_file" > /dev/null; then
          temporary_file="$(${pkgs.coreutils}/bin/mktemp "$config_file.tmp.XXXXXX")"
          ${pkgs.jq}/bin/jq --argjson managed "$managed_config" \
            '. * $managed' "$config_file" > "$temporary_file"
          ${pkgs.coreutils}/bin/mv "$temporary_file" "$config_file"
        else
          echo "Pear Desktop config is invalid JSON; leaving it unchanged: $config_file" >&2
        fi
      fi
    '';
  };
}
