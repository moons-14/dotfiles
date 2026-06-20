{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.nix-index.system;
in
{
  imports = [ inputs.nix-index-database.nixosModules.default ];

  options.my.applications.nix-index.system = {
    enable = lib.mkEnableOption "nix-index system configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-index-database.comma.enable = true;
  };
}
