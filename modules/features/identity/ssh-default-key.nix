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
    enable = lib.mkEnableOption "Generate default SSH client key (ed25519)";
  };

  config.home-manager.sharedModules = [
    (
      { lib, ... }:
      {
        config = lib.mkIf cfg.enable {
          systemd.user.services.generate-default-ssh-key = {
            Unit = {
              Description = "Generate the default SSH client key";
              ConditionPathExists = "!%h/.ssh/id_ed25519";
            };

            Service = {
              Type = "oneshot";
              ExecStartPre = [
                "${pkgs.coreutils}/bin/mkdir -p %h/.ssh"
                "${pkgs.coreutils}/bin/chmod 700 %h/.ssh"
              ];
              ExecStart = ''${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N "" -f %h/.ssh/id_ed25519 -C "%u@%H"'';
            };

            Install.WantedBy = [ "default.target" ];
          };
        };
      }
    )
  ];
}
