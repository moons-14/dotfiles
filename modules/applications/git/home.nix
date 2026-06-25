{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.applications.git;
  hmCfg = config.my.applications.git.homeManager;

  sshCfg = config.my.applications.ssh;

  gitSshSigningKeyCommand = pkgs.writeShellScript "git-ssh-signing-key" ''
    set -u

    expand_path() {
      case "$1" in
        "~")
          printf '%s\n' "$HOME"
          ;;
        "~/"*)
          printf '%s\n' "$HOME/''${1#"~/"}"
          ;;
        *)
          printf '%s\n' "$1"
          ;;
      esac
    }

    fido_present() {
      ${pkgs.libfido2}/bin/fido2-token -L 2>/dev/null \
        | ${pkgs.gnugrep}/bin/grep -q .
    }

    is_ssh_public_key() {
      case "$1" in
        ssh-*|ecdsa-*|sk-*)
          return 0
          ;;
        *)
          return 1
          ;;
      esac
    }

    is_fido_public_key() {
      case "$1" in
        sk-*)
          return 0
          ;;
        *)
          return 1
          ;;
      esac
    }

    print_git_key() {
      key="$1"

      is_ssh_public_key "$key" || return 1

      printf 'key::%s\n' "$key"
      exit 0
    }

    pubkey_file_for_identity() {
      identity_file="$(expand_path "$1")"

      case "$identity_file" in
        *.pub)
          printf '%s\n' "$identity_file"
          ;;
        *)
          printf '%s.pub\n' "$identity_file"
          ;;
      esac
    }

    print_pubkey_file_as_git_key() {
      public_key_file="$1"

      [ -r "$public_key_file" ] || return 1

      IFS= read -r key < "$public_key_file" || return 1
      [ -n "$key" ] || return 1

      print_git_key "$key"
    }

    print_first_usable_agent_key() {
      [ -n "''${SSH_AUTH_SOCK:-}" ] || return 1
      [ -S "$SSH_AUTH_SOCK" ] || return 1

      has_fido=0
      if fido_present; then
        has_fido=1
      fi

      ${pkgs.openssh}/bin/ssh-add -L 2>/dev/null \
        | while IFS= read -r key; do
            is_ssh_public_key "$key" || continue

            # YubiKey が無いときに agent に残っている sk-* 鍵を選ぶと、
            # Git 署名時に "agent refused operation" になる。
            if is_fido_public_key "$key" && [ "$has_fido" -ne 1 ]; then
              continue
            fi

            print_git_key "$key"
          done
    }

    add_identity_to_agent_and_print_pubkey() {
      identity_file="$(expand_path "$1")"
      public_key_file="$(pubkey_file_for_identity "$1")"

      [ -r "$identity_file" ] || return 1
      [ -r "$public_key_file" ] || return 1

      [ -n "''${SSH_AUTH_SOCK:-}" ] || return 1
      [ -S "$SSH_AUTH_SOCK" ] || return 1

      ${pkgs.openssh}/bin/ssh-add -q "$identity_file" >/dev/null 2>&1 || return 1

      print_pubkey_file_as_git_key "$public_key_file"
    }

    # 1. agent にすでにある鍵を優先する。
    # ただし YubiKey が無い場合、stale な sk-* 鍵は無視する。
    print_first_usable_agent_key || true

    # 2. YubiKey が刺さっている場合だけ _sk_rk を追加して使う。
    if fido_present; then
      add_identity_to_agent_and_print_pubkey ${lib.escapeShellArg sshCfg.fidoIdentityFile} || true
    fi

    # 3. 最後に通常のローカル鍵を agent に追加して使う。
    ${lib.concatMapStringsSep "\n" (
      identityFile: "add_identity_to_agent_and_print_pubkey ${lib.escapeShellArg identityFile} || true"
    ) sshCfg.defaultIdentityFiles}

    printf '%s\n' "git-ssh-signing-key: no usable SSH signing key found" >&2
    exit 1
  '';

in
{
  options.my.applications.git.homeManager = {
    enable = lib.mkEnableOption "git home-manager configuration";
  };

  config = lib.mkIf hmCfg.enable {
    home-manager.sharedModules = [
      {
        programs.git = {
          enable = true;

          ignores = [
            ".direnv/"
            ".envrc"
            "!.envrc.example"
          ];

          settings = {
            user.name = cfg.userName;
            user.email = cfg.userEmail;

            push.default = "simple";
            credential.helper = "cache --timeout=7200";
            init.defaultBranch = "main";
            log.decorate = "full";
            log.date = "iso";
            merge.conflictStyle = "diff3";

            # SSH signing
            gpg.format = "ssh";

            # Git の SSH signing backend はデフォルトでも ssh-keygen だが、
            # store path に固定して PATH 依存を避ける。
            gpg.ssh.program = "${pkgs.openssh}/bin/ssh-keygen";

            # user.signingKey は固定しない。
            # 署名時にこの command が key::ssh-ed25519 ... を返す。
            gpg.ssh.defaultKeyCommand = "${gitSshSigningKeyCommand}";

            commit.gpgSign = true;
            tag.gpgSign = true;

            alias = {
              br = "branch --sort=-committerdate";
              co = "checkout";
              df = "diff";
              com = "commit -a";
              gs = "stash";
              gp = "pull";
              lg = "log --graph --pretty=format:'%Cred%h%Creset - %C(yellow)%d%Creset %s %C(green)(%cr)%C(bold blue) <%an>%Creset' --abbrev-commit";
              st = "status";
            };
          };
        };
      }
    ];
  };
}
