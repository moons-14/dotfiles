{
  config,
  lib,
  pkgs,
  host,
  ...
}:
{

  home.packages = [ pkgs.openssh ];

  programs.ssh = {
    enable = true;

    matchBlocks = {
      "monitor.moons14.com" = {
        host = "monitor.moons14.com";
        identityFile = "~/.ssh/id_ed25519_sk_rk";
        identitiesOnly = true;
      };

      "dev-1.moons14.com" = {
        host = "dev-1.moons14.com";
        identityFile = "~/.ssh/id_ed25519_sk_rk";
        identitiesOnly = true;
      };

      "service-1.moons14.com" = {
        host = "service-1.moons14.com";
        identityFile = "~/.ssh/id_ed25519_sk_rk";
        identitiesOnly = true;
      };
    };

    extraConfig = ''
      Host *
        AddKeysToAgent yes
        IdentityFile ~/.ssh/id_ed25519
    '';
  };

  home.activation.generateSshKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    key="$HOME/.ssh/id_ed25519"
    if [ ! -f "$key" ]; then
      umask 077
      mkdir -p "$HOME/.ssh"
      ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N "" -f "$key" \
        -C "moons@$(${host} || echo host)"
      echo "Generated SSH key at $key"
    fi
  '';

  programs.git = {
    enable = true;

    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    extraConfig = {
      gpg.format = "ssh";
      tag.gpgSign = true;
    };
  };
}
