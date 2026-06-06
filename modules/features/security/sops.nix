{
  config,
  lib,
  ...
}:
let
  cfg = config.my.features.security.sops;
in
{
  options.my.features.security.sops = {
    defaultSopsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Default encrypted SOPS file for host secrets.";
    };

    userPassword.enable = lib.mkEnableOption "hashed password for the primary user from sops-nix";
  };

  config.my.system.secrets.sops = {
    inherit (cfg) defaultSopsFile;
    userPassword.enable = cfg.userPassword.enable;
  };
}
