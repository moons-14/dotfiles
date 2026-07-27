{ pkgs, ... }:
let
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
  home.packages = [ pkgs.gh ];

  home.file.${signingKeyPath}.text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLwReAiwhXoO34S2+MrvqUhi8IWp4IzUq4OSp3niJdq 1password-git-signing
  '';

  programs.git = {
    enable = true;

    ignores = [
      ".direnv/"
      ".envrc"
      "!.envrc.example"
    ];

    signing = {
      key = signingKeyFile;
      format = "ssh";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "moons";
        email = "moons@moons14.com";
      };

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
