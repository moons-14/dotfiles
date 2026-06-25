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

    print_key_line() {
      key="$1"

      case "$key" in
        ssh-*|ecdsa-*|sk-*)
          printf 'key::%s\n' "$key"
          exit 0
          ;;
      esac
    }

    print_pub_from_identity_file() {
      identity_file="$(expand_path "$1")"

      case "$identity_file" in
        *.pub)
          public_key_file="$identity_file"
          ;;
        *)
          public_key_file="$identity_file.pub"
          ;;
      esac

      if [ ! -r "$public_key_file" ]; then
        return 1
      fi

      IFS= read -r key < "$public_key_file" || return 1
      [ -n "$key" ] || return 1

      print_key_line "$key"
    }

    # 1. まず現在の SSH agent を優先する。
    #
    # ローカル端末なら NixOS の ssh-agent。
    # SSH agent forwarding 先なら forwarded agent。
    #
    # Git はここで返した公開鍵に対応する秘密鍵を ssh-agent 経由で使う。
    if [ -n "''${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
      while IFS= read -r key; do
        print_key_line "$key"
      done <<EOF
    $(${pkgs.openssh}/bin/ssh-add -L 2>/dev/null || true)
    EOF
    fi

    # 2. agent に使える鍵が無ければ、YubiKey が見えている場合だけ _sk_rk を使う。
    #
    # _sk_rk ファイルの存在では判定しない。
    fido_devices="$(${pkgs.libfido2}/bin/fido2-token -L 2>/dev/null || true)"
    if [ -n "$fido_devices" ]; then
      print_pub_from_identity_file ${lib.escapeShellArg sshCfg.fidoIdentityFile} || true
    fi

    # 3. 最後に通常のローカル identity へ fallback する。
    ${lib.concatMapStringsSep "\n" (
      identityFile: "print_pub_from_identity_file ${lib.escapeShellArg identityFile} || true"
    ) sshCfg.defaultIdentityFiles}

    printf '%s\n' "git-ssh-signing-key: no usable SSH signing public key found" >&2
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
