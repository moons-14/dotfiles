{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications."1password";
in
{
  options.my.applications."1password" = {
    enable = lib.mkEnableOption "1Password password manager";
  };

  config = lib.mkIf cfg.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "moons" ];
    };
  };
}
