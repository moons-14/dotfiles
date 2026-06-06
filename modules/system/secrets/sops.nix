{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.my.system.secrets.sops;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.my.system.secrets.sops = {
    ageKeyFile = lib.mkOption {
      type = lib.types.path;
      default = /var/lib/sops-nix/key.txt;
      description = "Path to the host age key used by sops-nix.";
    };

    generateKey = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Generate the host age key at ageKeyFile when it does not exist.";
    };

    defaultSopsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Default encrypted SOPS file for host secrets.";
    };

    userPassword = {
      enable = lib.mkEnableOption "hashed password for the primary user from sops-nix";

      secretName = lib.mkOption {
        type = lib.types.str;
        default = "users/${username}/hashedPassword";
        description = "SOPS secret name containing the hashed password for the primary user.";
      };
    };
  };

  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        age # File encryption tool used with sops-nix age keys
        sops # Editor and CLI for SOPS encrypted secrets
        ssh-to-age # Convert SSH public keys to age recipients
      ];

      sops = {
        age = {
          keyFile = cfg.ageKeyFile;
          inherit (cfg) generateKey;
        };
      };
    }

    (lib.mkIf (cfg.defaultSopsFile != null) {
      sops.defaultSopsFile = cfg.defaultSopsFile;
    })

    (lib.mkIf cfg.userPassword.enable {
      assertions = [
        {
          assertion = cfg.defaultSopsFile != null;
          message = "my.system.secrets.sops.userPassword.enable requires my.system.secrets.sops.defaultSopsFile.";
        }
      ];

      sops.secrets.${cfg.userPassword.secretName} = {
        neededForUsers = true;
      };

      users.mutableUsers = false;
      users.users.${username}.hashedPasswordFile = config.sops.secrets.${cfg.userPassword.secretName}.path;
    })
  ];
}
