{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  handy = inputs.handy.packages.${pkgs.stdenv.hostPlatform.system}.handy;
  settingsFile = "${config.xdg.configHome}/com.pais.handy/settings_store.json";
in
{
  home.packages = [
    handy
    pkgs.wtype
  ];

  # Handy has no disabled-shortcut setting. Empty bindings are rejected before
  # registration, leaving niri and labwc as the sole owners of Ctrl+Space.
  home.activation.disableHandyGlobalShortcuts = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      settingsFile=${lib.escapeShellArg settingsFile}
      mkdir -p "$(dirname "$settingsFile")"

      if [ -f "$settingsFile" ]; then
        ${lib.getExe pkgs.jq} \
          '.settings.bindings.transcribe.current_binding = ""
          | .settings.bindings.transcribe_with_post_process.current_binding = ""' \
          "$settingsFile" > "$settingsFile.tmp"
      else
        ${lib.getExe pkgs.jq} -n '
          {
            settings: {
              bindings: {
                transcribe: {
                  id: "transcribe",
                  name: "Transcribe",
                  description: "Converts your speech into text.",
                  default_binding: "ctrl+space",
                  current_binding: ""
                },
                transcribe_with_post_process: {
                  id: "transcribe_with_post_process",
                  name: "Transcribe with Post-Processing",
                  description: "Converts your speech into text and applies AI post-processing.",
                  default_binding: "ctrl+shift+space",
                  current_binding: ""
                }
              }
            }
          }
        ' > "$settingsFile.tmp"
      fi

      mv "$settingsFile.tmp" "$settingsFile"
    '';
  };

  systemd.user.services.handy = {
    Unit = {
      Description = "Handy speech-to-text";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${lib.getExe handy} --start-hidden";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
