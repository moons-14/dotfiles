{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  codexSessionUsage = inputs.codex-session-usage.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = [ codexSessionUsage ];

  xdg.dataFile = {
    "vicinae/scripts/codex-session-usage/start" = {
      executable = true;
      text = ''
        #!${lib.getExe pkgs.bash}
        # @vicinae.schemaVersion 1
        # @vicinae.title Start Codex Session Usage
        # @vicinae.description Start the local Codex session usage dashboard
        # @vicinae.mode compact
        # @vicinae.icon 📊
        # @vicinae.argument1 { "type": "text", "placeholder": "Port (optional)", "optional": true }

        if [[ -z "$1" ]]; then
          exec ${lib.getExe codexSessionUsage} start
        fi

        if [[ "$1" =~ ^[0-9]+$ ]] && (( 10#$1 >= 1 && 10#$1 <= 65535 )); then
          exec ${lib.getExe codexSessionUsage} start --port "$1"
        fi

        printf '%s\n' 'Port must be an integer between 1 and 65535.' >&2
        exit 2
      '';
    };

    "vicinae/scripts/codex-session-usage/stop" = {
      executable = true;
      text = ''
        #!${lib.getExe pkgs.bash}
        # @vicinae.schemaVersion 1
        # @vicinae.title Stop Codex Session Usage
        # @vicinae.description Stop the local Codex session usage dashboard
        # @vicinae.mode compact
        # @vicinae.icon 📊

        exec ${lib.getExe codexSessionUsage} stop
      '';
    };
  };
}
