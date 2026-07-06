{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.git;
  hmCfg = config.my.applications.git.homeManager;

  signingKeyPath = ".ssh/1password-git-signing.pub";
  signingKeyFile = "~/${signingKeyPath}";

  gitSshSign = pkgs.writeShellScript "git-ssh-sign" ''
    one_password_sock="$HOME/.1password/agent.sock"

    if { [ -n "''${SSH_CONNECTION:-}" ] || [ -n "''${SSH_CLIENT:-}" ]; } \
      && [ -n "''${SSH_AUTH_SOCK:-}" ] \
      && [ -S "$SSH_AUTH_SOCK" ]; then
      exec ${pkgs.openssh}/bin/ssh-keygen "$@"
    fi

    if [ -S "$one_password_sock" ]; then
      export SSH_AUTH_SOCK="$one_password_sock"
      exec ${pkgs.openssh}/bin/ssh-keygen "$@"
    fi

    if [ -n "''${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
      exec ${pkgs.openssh}/bin/ssh-keygen "$@"
    fi

    echo "git ssh signing failed: no forwarded SSH agent or 1Password agent socket found" >&2
    echo "expected: forwarded SSH_AUTH_SOCK or $one_password_sock" >&2
    exit 1
  '';
in
{
  options.my.applications.git.homeManager = {
    enable = lib.mkEnableOption "git home-manager configuration";

    signingPublicKey = lib.mkOption {
      type = lib.types.nullOr lib.types.singleLineStr;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLwReAiwhXoO34S2+MrvqUhi8IWp4IzUq4OSp3niJdq 1password-git-signing";
      example = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLwReAiwhXoO34S2+MrvqUhi8IWp4IzUq4OSp3niJdq 1password-git-signing";
      description = "SSH public key copied from the 1Password SSH key item used for Git signing.";
    };

    signingKey = lib.mkOption {
      type = lib.types.str;
      default = signingKeyFile;
      readOnly = true;
      description = "SSH public key path used for Git commit and tag signing.";
    };
  };

  config = lib.mkIf hmCfg.enable {
    assertions = [
      {
        assertion = hmCfg.signingPublicKey != null && hmCfg.signingPublicKey != "";
        message = "my.applications.git.homeManager.signingPublicKey must be set to the public key copied from 1Password.";
      }
    ];

    home-manager.sharedModules = [
      {
        home.file.${signingKeyPath}.text = hmCfg.signingPublicKey + "\n";

        programs.git = {
          enable = true;

          ignores = [
            ".direnv/"
            ".envrc"
            "!.envrc.example"
          ];

          signing = {
            key = hmCfg.signingKey;
            format = "ssh";
            signByDefault = true;
          };

          settings = {
            user.name = cfg.userName;
            user.email = cfg.userEmail;

            push.default = "simple";
            credential.helper = "cache --timeout=7200";
            init.defaultBranch = "main";
            log.decorate = "full";
            log.date = "iso";
            merge.conflictStyle = "diff3";

            gpg.ssh.program = "${gitSshSign}";

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
