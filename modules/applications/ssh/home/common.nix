{ lib, pkgs, ... }:
lib.mkMerge [
  {
    home.packages = [ pkgs.openssh ];

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "github.com" = {
          HostName = "github.com";
          User = "git";
          AddKeysToAgent = "no";
        };
        "*.sfc.wide.ad.jp" = {
          identityFile = "~/.ssh/id_ed25519_sk_rk";
          identitiesOnly = true;
        };
        "*" = {
          AddKeysToAgent = "no";
          SetEnv.TERM = "xterm-256color";
        };
      };

      extraConfig = ''
        Match exec "test -n \"$SSH_AUTH_SOCK\" && test -S \"$SSH_AUTH_SOCK\""
          IdentityAgent $SSH_AUTH_SOCK

        Match exec "test -S %d/.1password/agent.sock"
          IdentityAgent %d/.1password/agent.sock
      '';
    };

    home.activation.generateSshKey = {
      after = [ "writeBoundary" ];
      before = [ ];
      data = ''
        key="$HOME/.ssh/id_ed25519"
        if [ ! -f "$key" ]; then
          umask 077
          mkdir -p "$HOME/.ssh"
          ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N "" -f "$key" \
            -C "moons@$(${pkgs.hostname}/bin/hostname || echo host)"
          echo "Generated SSH key at $key"
        fi
      '';
    };
  }
]
