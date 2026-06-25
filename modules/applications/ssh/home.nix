{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.applications.ssh;
  hmCfg = config.my.applications.ssh.homeManager;

  shellPathExpr =
    path:
    if lib.hasPrefix "~/" path then
      ''"$HOME/${lib.removePrefix "~/" path}"''
    else
      lib.escapeShellArg path;

  fidoIdentityExpr = shellPathExpr cfg.fidoIdentityFile;

  hasFidoDevice = pkgs.writeShellScript "ssh-has-fido-device" ''
    ${pkgs.libfido2}/bin/fido2-token -L 2>/dev/null \
      | ${pkgs.gnugrep}/bin/grep -q .
  '';

  sshYubikeyAgentSync = pkgs.writeShellApplication {
    name = "ssh-yubikey-agent-sync";

    runtimeInputs = with pkgs; [
      openssh
      libfido2
      coreutils
      gnugrep
      gawk
    ];

    text = ''
      set -u

      force=0

      case "''${1:-}" in
        "")
          ;;
        "--force")
          force=1
          ;;
        *)
          printf '%s\n' "usage: ssh-yubikey-agent-sync [--force]" >&2
          exit 2
          ;;
      esac

      if [ -z "''${XDG_RUNTIME_DIR:-}" ]; then
        exit 0
      fi

      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"

      if [ ! -S "$SSH_AUTH_SOCK" ]; then
        exit 0
      fi

      fido_identity=${fidoIdentityExpr}
      fido_public_key="$fido_identity.pub"

      state_dir="$XDG_RUNTIME_DIR/ssh-yubikey-agent-sync"
      state_file="$state_dir/fido-device-state"

      mkdir -p "$state_dir"

      fido_present() {
        fido2-token -L 2>/dev/null | grep -q .
      }

      fido_state() {
        fido2-token -L 2>/dev/null | sha256sum | awk '{ print $1 }'
      }

      pub_fingerprint() {
        [ -r "$1" ] || return 1
        ssh-keygen -lf "$1" -E sha256 2>/dev/null | awk '{ print $2 }'
      }

      agent_has_public_key() {
        public_key_file="$1"

        fingerprint="$(pub_fingerprint "$public_key_file")" || return 1

        ssh-add -l -E sha256 2>/dev/null \
          | grep -Fq "$fingerprint"
      }

      remove_fido_from_agent() {
        ssh-add -d "$fido_identity" >/dev/null 2>&1 || true
        ssh-add -d "$fido_public_key" >/dev/null 2>&1 || true
      }

      add_fido_to_agent() {
        [ -r "$fido_identity" ] || exit 0
        [ -r "$fido_public_key" ] || exit 0

        remove_fido_from_agent

        ssh-add -q -t "''${SSH_YUBIKEY_AGENT_LIFETIME:-24h}" "$fido_identity" >/dev/null 2>&1 || exit 0
      }

      if fido_present; then
        new_state="$(fido_state)"
        old_state="$(cat "$state_file" 2>/dev/null || true)"

        if [ "$force" -eq 1 ] \
          || ! agent_has_public_key "$fido_public_key" \
          || [ "$new_state" != "$old_state" ]; then
          add_fido_to_agent
          printf '%s\n' "$new_state" > "$state_file"
        fi
      else
        remove_fido_from_agent
        rm -f "$state_file"
      fi
    '';
  };

  userMatchBlockNames = lib.attrNames (cfg.matchBlocks or { });

  userMatchBlocks = lib.mapAttrs (
    _name: value: lib.hm.dag.entryBefore [ "my-github" "my-default" ] value
  ) (cfg.matchBlocks or { });

  githubBlock = {
    header = "Host github.com";

    HostName = "github.com";
    User = "git";

    IdentityAgent = "SSH_AUTH_SOCK";
    IdentitiesOnly = false;
    ForwardAgent = false;

    AddKeysToAgent = cfg.addKeysToAgent;
  }
  // lib.optionalAttrs (cfg.githubIdentityFiles != [ ]) {
    IdentityFile = cfg.githubIdentityFiles;
  };

in
{
  options.my.applications.ssh.homeManager = {
    enable = lib.mkEnableOption "SSH home-manager configuration";
  };

  config.home-manager.sharedModules = [
    (
      { lib, ... }:
      {
        config = lib.mkIf hmCfg.enable {
          home.packages = [
            sshYubikeyAgentSync
          ];

          systemd.user.services.ssh-yubikey-agent-sync = {
            Unit = {
              Description = "Synchronize YubiKey SSH key with ssh-agent";
            };

            Service = {
              Type = "oneshot";

              # NixOS programs.ssh.startAgent の socket。
              Environment = [
                "SSH_AUTH_SOCK=%t/ssh-agent"
                "SSH_YUBIKEY_AGENT_LIFETIME=24h"
              ];

              ExecStart = "${sshYubikeyAgentSync}/bin/ssh-yubikey-agent-sync";
            };
          };

          systemd.user.timers.ssh-yubikey-agent-sync = {
            Unit = {
              Description = "Periodically synchronize YubiKey SSH key with ssh-agent";
            };

            Timer = {
              OnBootSec = "5s";
              OnUnitActiveSec = "10s";
              AccuracySec = "2s";
              Unit = "ssh-yubikey-agent-sync.service";
            };

            Install = {
              WantedBy = [ "timers.target" ];
            };
          };

          programs.ssh = {
            enable = true;
            enableDefaultConfig = false;

            settings = userMatchBlocks // {
              "my-local-fido-sk-rk" =
                lib.hm.dag.entryBefore
                  (
                    [
                      "my-github"
                      "my-default"
                    ]
                    ++ userMatchBlockNames
                  )
                  {
                    header = ''Match exec "${hasFidoDevice}"'';

                    IdentityFile = cfg.fidoIdentityFile;

                    # FIDO key の agent 登録は ssh-yubikey-agent-sync に任せる。
                    #
                    # ここで AddKeysToAgent を有効にすると、
                    # YubiKey 抜き差し後に stale な agent entry が残りやすい。
                    AddKeysToAgent = "no";
                  };

              "my-github" = lib.hm.dag.entryBefore [ "my-default" ] githubBlock;

              "my-default" =
                lib.hm.dag.entryAfter
                  (
                    [
                      "my-local-fido-sk-rk"
                      "my-github"
                    ]
                    ++ userMatchBlockNames
                  )
                  {
                    header = "Host *";

                    IdentityAgent = "SSH_AUTH_SOCK";
                    IdentitiesOnly = false;

                    # default deny。
                    # agent forwarding したい host だけ cfg.matchBlocks 側で true にする。
                    ForwardAgent = false;

                    IdentityFile = cfg.defaultIdentityFiles;

                    AddKeysToAgent = cfg.addKeysToAgent;

                    SetEnv = {
                      TERM = "xterm";
                    };
                  };
            };
          };
        };
      }
    )
  ];
}
