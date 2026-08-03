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
        Match exec "test -S %d/.1password/agent.sock"
          IdentityAgent %d/.1password/agent.sock
      '';
    };
  }
]
