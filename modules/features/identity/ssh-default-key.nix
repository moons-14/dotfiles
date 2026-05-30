{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.identity.sshDefaultKey;
in
{
  options.my.features.identity.sshDefaultKey = {
    enable = lib.mkEnableOption "Generate default SSH key (ed25519)";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf cfg.enable {
        home.activation.generateSshKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
  ];
}
